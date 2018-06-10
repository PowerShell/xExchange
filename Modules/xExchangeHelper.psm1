#Gets the existing Remote PowerShell session to Exchange, if it exists
function GetExistingExchangeSession
{
    return (Get-PSSession -Name "DSCExchangeSession" -ErrorAction SilentlyContinue)
}

#Establishes a Exchange remote powershell session to the local server. Reuses the session if it already exists.
function GetRemoteExchangeSession
{
    [CmdletBinding()]
    param
    (
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,
        
        [System.String[]]
        $CommandsToLoad,
        
        $VerbosePreference,
        
        $SetupProcessName = "ExSetup*"
    )

    #Check if Exchange Setup is running. If so, we need to throw an exception, as a running Exchange DSC resource will block Exchange Setup from working properly.
    if (IsSetupRunning -SetupProcessName $SetupProcessName)
    {
        throw "Exchange Setup is currently running. Preventing creation of new Remote PowerShell session to Exchange."
    }

    #See if the session already exists
    $Session = GetExistingExchangeSession

    #Attempt to reuse the session if we found one
    if ($null -ne $Session)
    {
        if ($Session.State -eq "Opened")
        {
            Write-Verbose "Reusing existing Remote Powershell Session to Exchange"
        }
        else #Session is in an unexpected state. Remove it so we can rebuild it
        {
            RemoveExistingRemoteSession
            $Session = $null
        }
    }

    #Either the session didn't exist, or it was broken and we nulled it out. Create a new one
    if ($null -eq $Session)
    {
        #First make sure we are on a valid server version, and that Exchange is fully installed
        VerifyServerVersion -VerbosePreference $VerbosePreference

        Write-Verbose "Creating new Remote Powershell session to Exchange"

        #Get local server FQDN
        $machineDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain.ToLower()
        $serverName = $env:computername.ToLower()
        $serverFQDN = $serverName + "." + $machineDomain

        #Override chatty banner, because chatty
        New-Alias Get-ExBanner Out-Null
        New-Alias Get-Tip Out-Null

        #Load built in Exchange functions, and create session
        $exbin = Join-Path -Path ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup).MsiInstallPath) -ChildPath "bin"
        $remoteExchange = Join-Path -Path "$($exbin)" -ChildPath "RemoteExchange.ps1"
        . $remoteExchange
        $Session = _NewExchangeRunspace -fqdn $serverFQDN -credential $Credential -UseWIA $false -AllowRedirection $false
        
        #Remove the aliases we created earlier
        Remove-Item Alias:Get-ExBanner
        Remove-Item Alias:Get-Tip

        if ($null -ne $Session)
        {
            $Session.Name = "DSCExchangeSession"
        }
    }
    
    #If the session is still null here, things went wrong. Throw exception
    if ($null -eq $Session)
    {
        throw "Failed to establish remote Powershell session to FQDN: $($serverFQDN)"
    }
    else #Import the session globally
    {
        #Temporarily set Verbose to SilentlyContinue so the Session and Module import isn't noisy
        $oldVerbose = $VerbosePreference
        $VerbosePreference = "SilentlyContinue"

        if ($CommandsToLoad.Count -gt 0)
        {
            $moduleInfo = Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -CommandName $CommandsToLoad -Verbose:0
        }
        else
        {
            $moduleInfo = Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -Verbose:0
        }

        Import-Module $moduleInfo -Global -DisableNameChecking

        #Set Verbose back
        $VerbosePreference = $oldVerbose
    }   
}

#Removes any Remote Sessions that have been setup by us
function RemoveExistingRemoteSession
{
    [CmdletBinding()]
    param($VerbosePreference)

    $sessions = GetExistingExchangeSession

    if ($null -ne $sessions)
    {
        Write-Verbose "Removing existing remote Powershell sessions"

        GetExistingExchangeSession | Remove-PSSession
    }
}

#Ensures that Exchange is installed, and that it is the correct version (2013 or 2016)
function VerifyServerVersion
{
    [CmdletBinding()]
    param($VerbosePreference)

    $unsupportedMsg = "A supported version of Exchange is either not present, or not fully installed on this machine."

    if ($Global:ServerVersionGood -eq $true)
    {
        #Do nothing
    }
    elseif ($Global:ServerVersionGood -eq $false)
    {
        throw $unsupportedMsg
    }
    else
    {
        $setupComplete = IsSetupComplete

        if ($setupComplete -eq $false)
        {
            $Global:ServerVersionGood = $false

            throw $unsupportedMsg
        }
        else
        {
            $Global:ServerVersionGood = $true
        }
    }
}

#Gets the WMI object corresponding to the Exchange Product
function GetExchangeProduct
{
    if ($null -eq $Global:CheckedExchangeProduct -or $Global:CheckedExchangeProduct -eq $false)
    {
        $Global:ExchangeProduct = Get-CimInstance -ClassName Win32_Product -Filter 'Name like "Microsoft Exchange Server"'

        $Global:CheckedExchangeProduct = $true
    }

    return $Global:ExchangeProduct
}

#Checks whether a supported version of Exchange is at least partially installed by looking for Exchange's product GUID
function IsExchangePresent
{   
    $version = GetExchangeVersion

    if ($version -eq "2013" -or $version -eq "2016")
    {
        return $true
    }
    else
    {
        return $false
    }
}

#Gets the installed Exchange Version, and returns the number as a string.
#Returns N/A if the version cannot be found, and will optionally throw an exception
#if ThrowIfUnknownVersion was set to $true.
function GetExchangeVersion
{
    param ([bool]$ThrowIfUnknownVersion = $false)
    
    $version = "N/A"

    $product = GetExchangeProduct
    
    if ($null -ne $product)
    {
        if ($product.IdentifyingNumber -eq '{4934D1EA-BE46-48B1-8847-F1AF20E892C1}') #Exchange 2013
        {
            return "2013"
        }
        elseif($product.IdentifyingNumber -eq '{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}') #Exchange 2016
        {
            return "2016"
        }     
    }

    if ($version -eq "N/A" -and $ThrowIfUnknownVersion)
    {
        throw "Failed to discover a known Exchange Version"
    }
}

#Checks whether Setup fully completed
function IsSetupComplete
{
    $exchangePresent = IsExchangePresent
    $setupPartiallyCompleted = IsSetupPartiallyCompleted

    if ($exchangePresent -eq $true -and $setupPartiallyCompleted -eq $false)
    {
        $isSetupComplete = $true
    }
    else
    {
        $isSetupComplete = $false
    }

    return $isSetupComplete
}

#Checks whether any Setup watermark keys exist which means that a previous installation of setup had already started but not completed
function IsSetupPartiallyCompleted
{
    $isPartiallyCompleted = $false

    #Now check if setup actually completed successfully
    [System.String[]]$roleKeys = "CafeRole","ClientAccessRole","FrontendTransportRole","HubTransportRole","MailboxRole","UnifiedMessagingRole"

    foreach ($key in $roleKeys)
    {
        $values = $null
        $values = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$($key)" -ErrorAction SilentlyContinue

        if ($null -ne $values)
        {
            if ($null -ne $values.UnpackedVersion)
            {
                #If ConfiguredVersion is missing, or Action or Watermark or present, setup needs to be resumed
                if ($null -eq $values.ConfiguredVersion -or $null -ne $values.Action -or $null -ne $values.Watermark)
                {
                    $isPartiallyCompleted = $true
                    break
                }
            }
        }
    }
    
    return $isPartiallyCompleted
}

#Checks whether setup is running by looking for if the ExSetup.exe process currently exists
function IsSetupRunning
{
    param([System.String]$SetupProcessName = "ExSetup*")

    return ($null -ne (Get-Process -Name $SetupProcessName -ErrorAction SilentlyContinue))
}

#Checks if two strings are equal, or are both either null or empty
function CompareStrings
{
    param([System.String]$String1, [System.String]$String2, [switch]$IgnoreCase)

    if (([System.String]::IsNullOrEmpty($String1) -and [System.String]::IsNullOrEmpty($String2)))
    {
        return $true
    }
    else
    {
        if ($IgnoreCase -eq $true)
        {
            return ($String1 -like $String2)
        }
        else
        {
            return ($String1 -clike $String2)
        }
    }
}

#Checks if two bools are equal, or are both either null or false
function CompareBools($Bool1, $Bool2)
{
    if($Bool1 -ne $Bool2)
    {
        if (!(($null -eq $Bool1 -and $Bool2 -eq $false) -or ($null -eq $Bool2 -and $Bool1 -eq $false)))
        {
            return $false
        }
    }

    return $true
}

#Takes a string which should be in timespan format, and compares it to an actual EnhancedTimeSpan object. Returns true if they are equal
function CompareTimespanWithString
{
    param([Microsoft.Exchange.Data.EnhancedTimeSpan]$TimeSpan, [System.String]$String)

    try
    {
        $converted = [Microsoft.Exchange.Data.EnhancedTimeSpan]::Parse($String)

        return ($TimeSpan.Equals($converted))
    }
    catch
    {
        throw "String '$($String)' is not in a valid format for an EnhancedTimeSpan"
    }

    return $false
}

#Takes a string which should be in ByteQuantifiedSize format, and compares it to an actual ByteQuantifiedSize object. Returns true if they are equal
function CompareByteQuantifiedSizeWithString
{
    param([Microsoft.Exchange.Data.ByteQuantifiedSize]$ByteQuantifiedSize, [System.String]$String)

    try
    {
        $converted = [Microsoft.Exchange.Data.ByteQuantifiedSize]::Parse($String)

        return ($ByteQuantifiedSize.Equals($converted))
    }
    catch
    {
        throw "String '$($String)' is not in a valid format for a ByteQuantifiedSize"
    }
}

#Takes a string which should be in Microsoft.Exchange.Data.Unlimited format, and compares with an actual Unlimited object. Returns true if they are equal.
function CompareUnlimitedWithString
{
    param($Unlimited, [System.String]$String)

    if ($Unlimited.IsUnlimited)
    {
        return (CompareStrings -String1 "Unlimited" -String2 $String -IgnoreCase)
    }
    elseif ((CompareStrings -String1 "Unlimited" -String2 $String -IgnoreCase) -and !$Unlimited.IsUnlimited)
    {
        return $false
    }
    elseif (($Unlimited.Value -is [System.Int32]) -and !$Unlimited.IsUnlimited)
    {
        return (CompareStrings -String1 $Unlimited -String2 $String -IgnoreCase)
    }
    else
    {
        return (CompareByteQuantifiedSizeWithString -ByteQuantifiedSize $Unlimited -String $String)
    }
}

#Takes an ADObjectId, gets a mailbox from it, and checks if it's EmailAddresses property contains the given string.
#The Get-Mailbox cmdlet must be loaded for this function to succeed.
function CompareADObjectIdWithEmailAddressString
{
    param([Microsoft.Exchange.Data.Directory.ADObjectId]$ADObjectId, [System.String]$String)

    if ($null -ne (Get-Command Get-Mailbox -ErrorAction SilentlyContinue))
    {
        $mailbox = $ADObjectId | Get-Mailbox -ErrorAction SilentlyContinue

        return ($mailbox.EmailAddresses.Contains($String))
    }
    else
    {
        Write-Error "CompareADObjectIdWithEmailAddressString requires the Get-Mailbox cmdlert"

        return $false
    }  
}

#Takes a string containing a given separator, and breaks it into a string array
function StringToArray
{
    param([System.String]$StringIn, [char]$Separator)

    [System.String[]]$array = $StringIn.Split($Separator)

    for ($i = 0; $i -lt $array.Length; $i++)
    {
        $array[$i] = $array[$i].Trim()
    }

    return $array
}

#Takes an array of strings and converts all elements to lowercase
function StringArrayToLower
{
    param([System.String[]]$Array)
    
    for ($i = 0; $i -lt $Array.Count; $i++)
    {
        if (!([System.String]::IsNullOrEmpty($Array[$i])))
        {
            $Array[$i] = $Array[$i].ToLower()
        }
    }

    return $Array
}

#Checks whether two arrays have the same contents, where element order doesn't matter
function CompareArrayContents
{
    param([System.String[]]$Array1, [System.String[]]$Array2, [switch]$IgnoreCase)

    $hasSameContents = $true

    if ($Array1.Length -ne $Array2.Length)
    {
        $hasSameContents = $false
    }
    elseif ($Array1.Count -gt 0 -and $Array2.Count -gt 0)
    {
        if ($IgnoreCase -eq $true)
        {
            $Array1 = StringArrayToLower -Array $Array1
            $Array2 = StringArrayToLower -Array $Array2
        }

        foreach ($str in $Array1)
        {
            if (!($Array2.Contains($str)))
            {
                $hasSameContents = $false
                break
            }
        }
    }

    return $hasSameContents
}

#Checks whether Array2 contains all elements of Array1 (Array2 may be larger than Array1)
function Array2ContainsArray1Contents
{
    param([System.String[]]$Array1, [System.String[]]$Array2, [switch]$IgnoreCase)

    $hasContents = $true

    if ($Array1.Length -eq 0) #Do nothing, as Array2 at a minimum contains nothing    
    {} 
    elseif ($Array2.Length -eq 0) #Array2 is empty and Array1 is not. Return false
    {
        $hasContents = $false
    }
    else
    {
        if ($IgnoreCase -eq $true)
        {
            $Array1 = StringArrayToLower -Array $Array1
            $Array2 = StringArrayToLower -Array $Array2
        }

        foreach ($str in $Array1)
        {
            if (!($Array2.Contains($str)))
            {
                $hasContents = $false
                break
            }
        }
    }

    return $hasContents
}

#Takes $PSBoundParameters from another function and adds in the keys and values from the given Hashtable
function AddParameters
{
    param($PSBoundParametersIn, [Hashtable]$ParamsToAdd)

    foreach ($key in $ParamsToAdd.Keys)
    {
        if (!($PSBoundParametersIn.ContainsKey($key))) #Key doesn't exist, so add it with value
        {
            $PSBoundParametersIn.Add($key, $ParamsToAdd[$key]) | Out-Null
        }
        else #Key already exists, so just replace the value
        {
            $PSBoundParametersIn[$key] = $ParamsToAdd[$key]
        }
    }
}

#Takes $PSBoundParameters from another function. If ParamsToRemove is specified, it will remove each param.
#If ParamsToKeep is specified, everything but those params will be removed. If both ParamsToRemove and ParamsToKeep
#are specified, only ParamsToKeep will be used.
function RemoveParameters
{
    param($PSBoundParametersIn, [System.String[]]$ParamsToKeep, [System.String[]]$ParamsToRemove)

    if ($ParamsToKeep.Count -gt 0)
    {
        [System.String[]]$ParamsToRemove = @()

        $lowerParamsToKeep = StringArrayToLower -Array $ParamsToKeep

        foreach ($key in $PSBoundParametersIn.Keys)
        {
            if (!($lowerParamsToKeep.Contains($key.ToLower())))
            {
                $ParamsToRemove += $key
            }
        }
    }

    if ($ParamsToRemove.Count -gt 0)
    {
        foreach ($param in $ParamsToRemove)
        {
            $PSBoundParametersIn.Remove($param) | Out-Null
        }
    }
}

function RemoveVersionSpecificParameters
{
    param($PSBoundParametersIn, [System.String]$ParamName, [System.String]$ResourceName, [ValidateSet("2013","2016")][System.String]$ParamExistsInVersion)

    if ($PSBoundParametersIn.ContainsKey($ParamName))
    {
        $serverVersion = GetExchangeVersion

        if ($serverVersion -ne $ParamExistsInVersion)
        {
            Write-Warning "$($ParamName) is not a valid parameter for $($ResourceName) in Exchange $($serverVersion). Skipping usage."
            RemoveParameters -PSBoundParametersIn $PSBoundParametersIn -ParamsToRemove $ParamName
        }
    }
}

function SetEmptyStringParamsToNull
{
    param($PSBoundParametersIn)

    [System.String[]] $emptyStringKeys = @()

    #First find all parameters that are a string, and are an empty string ("")
    foreach ($key in $PSBoundParametersIn.Keys)
    {
        if ($null -ne $PSBoundParametersIn[$key] -and $PSBoundParametersIn[$key].GetType().Name -eq "String" -and $PSBoundParametersIn[$key] -eq "")
        {
            $emptyStringKeys += $key
        }
    }

    #Now that we have the keys, set their values to null
    foreach ($key in $emptyStringKeys)
    {
        $PSBoundParametersIn[$key] = $null
    }
}

function VerifySetting
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([System.String]$Name, [System.String]$Type, $ExpectedValue, $ActualValue, $PSBoundParametersIn, $VerbosePreference)

    $returnValue = $true

    if ($PSBoundParametersIn.ContainsKey($Name))
    {
        if ($Type -like "String")
        {
            if ((CompareStrings -String1 $ExpectedValue -String2 $ActualValue -IgnoreCase) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Boolean")
        {
            if ((CompareBools -Bool1 $ExpectedValue -Bool2 $ActualValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Array")
        {
            if ((CompareArrayContents -Array1 $ExpectedValue -Array2 $ActualValue -IgnoreCase) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Int")
        {
            if ($ExpectedValue -ne $ActualValue)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Unlimited")
        {
            if ((CompareUnlimitedWithString -Unlimited $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Timespan")
        {
            if ((CompareTimespanWithString -TimeSpan $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "ADObjectID")
        {
            if ((CompareADObjectIdWithEmailAddressString -ADObjectId $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "ByteQuantifiedSize")
        {
            if ((CompareByteQuantifiedSizeWithString -ByteQuantifiedSize $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "IPAddress")
        {
            if ((CompareIPAddresseWithString -IPAddress $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "IPAddresses")
        {
            if ((CompareIPAddressesWithArray -IPAddresses $ActualValue -Array $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "SMTPAddress")
        {
            if ((CompareSmtpAdressWithString -SmtpAddress $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "PSCredential")
        {
            if ((Compare-PSCredential -Cred1 $ActualValue -Cred2 $ExpectedValue ) -eq $false)
            {
                $returnValue = $false
            }        
        }
        elseif ($Type -like "ExtendedProtection")
        {
            if ((StringArrayToLower $ExpectedValue).Contains('none'))
            {
                if (-not [System.String]::IsNullOrEmpty($ActualValue))
                {
                    $returnValue = $false
                }
            }
            else
            {
                if ((CompareArrayContents -Array1 $ExpectedValue -Array2 $ActualValue -IgnoreCase) -eq $false)
                {
                    $returnValue = $false
                }
            }
        }
        else
        {
            throw "Type not found: $($Type)"
        }
    }

    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $Name -ExpectedValue $ExpectedValue -ActualValue $ActualValue -VerbosePreference $VerbosePreference
    }

    return $returnValue
}

function ReportBadSetting
{
    param($SettingName, $ExpectedValue, $ActualValue, $VerbosePreference)

    Write-Verbose "Invalid setting '$($SettingName)'. Expected value: '$($ExpectedValue)'. Actual value: '$($ActualValue)'"
}

function LogFunctionEntry
{
    param([Hashtable]$Parameters, $VerbosePreference)

    $callingFunction = (Get-PSCallStack)[1].FunctionName

    if ($Parameters.Count -gt 0)
    {
        $parametersString = ""

        foreach ($key in $Parameters.Keys)
        {
            $value = $Parameters[$key]

            if ($parametersString -ne "")
            {
                $parametersString += ", "
            }

            $parametersString += "$($key) = '$($value)'"
        }    

        Write-Verbose "Entering function '$($callingFunction)'. Notable parameters: $($parametersString)"
    }
    else
    {
        Write-Verbose "Entering function '$($callingFunction)'."
    }
}

function StartScheduledTask
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [System.String]
        $Arguments,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $TaskName,

        [System.String]
        $WorkingDirectory,

        [System.UInt32]
        $MaxWaitMinutes = 0,

        [System.UInt32]
        $TaskPriority = 4,

        $VerbosePreference
    )

    $tName = "$([guid]::NewGuid().ToString())"

    if ($PSBoundParameters.ContainsKey("TaskName"))
    {
        $tName = "$($TaskName) $($tName)"
    }

    $action = New-ScheduledTaskAction -Execute "$($Path)" -Argument "$($Arguments)"
    
    if ($PSBoundParameters.ContainsKey("WorkingDirectory"))
    {
        $action.WorkingDirectory = $WorkingDirectory
    }

    Write-Verbose "Created Scheduled Task with name: $($tName)"
    Write-Verbose "Task Action: $($Path) $($Arguments)"

    #Use 'NT AUTHORITY\SYSTEM' as the run as account unless a specific Credential was provided
    $credParams = @{User = "NT AUTHORITY\SYSTEM"}

    if ($PSBoundParameters.ContainsKey("Credential"))
    {
        $credParams["User"] = $Credential.UserName
        $credParams.Add("Password", $Credential.GetNetworkCredential().Password)
    }

    $task = Register-ScheduledTask @credParams -TaskName "$($tName)" -Action $action -RunLevel Highest -ErrorVariable errRegister -ErrorAction SilentlyContinue

    if (0 -lt $errRegister.Count)
    {
        throw $errRegister[0]
    }
    elseif ($null -ne $task -and $task.State -eq "Ready")
    {
        #Set a time limit on the task
        $taskSettings = $task.Settings
        $taskSettings.ExecutionTimeLimit = "PT$($MaxWaitMinutes)M"
        $taskSettings.Priority = $TaskPriority
        Set-ScheduledTask @credParams -TaskName "$($task.TaskName)" -Settings $taskSettings

        Write-Verbose "Starting task at: $([DateTime]::Now)"

        $task | Start-ScheduledTask
    }
    else
    {
        throw "Failed to register Scheduled Task"
    }
}

function CheckForCmdletParameter
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([System.String]$CmdletName, [System.String]$ParameterName)

    [bool]$hasParameter = $false

    $command = Get-Command -Name "$($CmdletName)" -ErrorAction SilentlyContinue

    if ($null -ne $command -and $null -ne $command.Parameters)
    {
        if ($command.Parameters.ContainsKey($ParameterName))
        {
            $hasParameter = $true
        }
    }

    return $hasParameter
}

function NotePreviousError
{
    $Global:previousError = $null

    if ($Global:error.Count -gt 0)
    {
        $Global:previousError = $Global:error[0]
    }    
}

function ThrowIfNewErrorsEncountered
{
    [CmdletBinding()]
    param([System.String]$CmdletBeingRun, $VerbosePreference)

    #Throw an exception if errors were encountered
    if ($Global:error.Count -gt 0 -and $Global:previousError -ne $Global:error[0])
    {
        [System.String]$errorMsg = "Failed to run $($CmdletBeingRun) with: " + $Global:error[0]
        Write-Error $errorMsg
        throw $errorMsg
    }
}

function RestartAppPoolIfExists
{
    [CmdletBinding()]
    param([System.String]$Name)

    $state = Get-WebAppPoolState -Name $Name -ErrorAction SilentlyContinue

    if ($null -ne $state)
    {
        Restart-WebAppPool -Name $Name
    }
    else
    {
        Write-Verbose "Application pool with name '$($Name)' does not exist. Skipping application pool restart."
    }
}

#Checks if the UM language pack for the specified culture is installed
function IsUMLanguagePackInstalled
{
    Param
    (
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Culture
    )

    return [bool](Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\UnifiedMessagingRole\LanguagePacks').$Culture
}

#Compares a single IPAddress with a string
function CompareIPAddresseWithString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([System.Net.IPAddress]$IPAddress, [System.String]$String)
    if (($null -eq $IPAddress -and !([System.String]::IsNullOrEmpty($String))) -or ($null -ne $IPAddress -and [System.String]::IsNullOrEmpty($String)))
    {
        $returnValue = $false
    }
    elseif ($null -eq $IPAddress -and [System.String]::IsNullOrEmpty($String))
    {
        $returnValue = $true
    }
    else
    {
        $returnValue =($IPAddress.Equals([System.Net.IPAddress]::Parse($string)))
    }
    
    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $IPAddress -ExpectedValue $ExpectedValue -ActualValue $IPAddress -VerbosePreference $VerbosePreference
    }
    return $returnValue
}

#Compares a SMTP address with a string
function CompareSmtpAdressWithString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param($SmtpAddress,[System.String]$String)
    if (($null -eq $SmtpAddress) -and ([System.String]::IsNullOrEmpty($String)))
    {
        Write-Verbose "Expected and actual value is empty, therefore equal!"
        return $true
    }
    elseif (($null -eq $SmtpAddress) -and -not ([System.String]::IsNullOrEmpty($String)))
    {
        return $false
    }
    elseif ($SmtpAddress.Gettype() -eq [Microsoft.Exchange.Data.SmtpAddress])
    {
        if ([System.String]::IsNullOrEmpty($String))
        {
            return $false
        }
        else
        {
            return($SmtpAddress.Equals([Microsoft.Exchange.Data.SmtpAddress]::Parse($string)))
        }
    }
    else
    {
        Write-Verbose "No type of [Microsoft.Exchange.Data.SmtpAddress]!"
        return $false
    }
}

#Compares IPAddresses with an array
function CompareIPAddressesWithArray
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param($IPAddresses, [Array]$Array)
    if (([System.String]::IsNullOrEmpty($IPAddresses)) -and ([System.String]::IsNullOrEmpty($Array)))
    {
        $returnValue = $true
    }
    elseif ((([System.String]::IsNullOrEmpty($IPAddresses)) -and !(([System.String]::IsNullOrEmpty($Array)))) -or (!(([System.String]::IsNullOrEmpty($IPAddresses))) -and ([System.String]::IsNullOrEmpty($Array))))
    {
        $returnValue = $false
    }
    else
    {
        CompareArrayContents -Array1 $IPAddresses -Array2 $Array
    }
    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $IPAddresses -ExpectedValue $ExpectedValue -ActualValue $IPAddress -VerbosePreference $VerbosePreference
    }
    return $returnValue
}

#Compares two give PSCredential
function Compare-PSCredential
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        #[System.Management.Automation.PSCredential]
        #[System.Management.Automation.Credential()]
        $Cred1,

        #[System.Management.Automation.PSCredential]
        #[System.Management.Automation.Credential()]
        $Cred2
    )
Begin {
    $returnValue = $false
    if ($null -ne $Cred1) {
        $Cred1User = $Cred1.UserName
        $Cred1Password = $Cred1.GetNetworkCredential().Password
    }
    if ($null -ne $Cred2) {
        $Cred2User = $Cred2.UserName
        $Cred2Password = $Cred2.GetNetworkCredential().Password
    }
}
Process {
    if (($Cred1User -ceq $Cred2User) -and ($Cred1Password -ceq $Cred2Password)){
        Write-Verbose "Credentials match"
        $returnValue = $true
    }
    else{
        Write-Verbose "Credentials don't match"
        Write-Verbose "Cred1:$($Cred1User) Cred2:$($Cred2User)"
        Write-Verbose "Cred1:$($Cred1Password) Cred2:$($Cred2Password)"
    }
}
End {
    return $returnValue
}
}

#helper function to convert Microsoft.Exchange.Data.MultiValuedPropertyBase to System.Array
function ConvertTo-Array
{
    [CmdletBinding()]
    [OutputType([System.Array])]
    param(
        [Object[]]$InputObject
    )
    Begin
    {
        $output = @()
    }
    Process
    {
        $InputObject | ForEach-Object -Process {$output += $_}
    }
    End
    {
        return $output 
    }
}

#helper function to check SPN for Dotless name
function Test-ExtendedProtectionSPNList
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param
    (
        [System.String[]]$SPNList,

        [System.String[]]$Flags
    )

    Begin
    {
        #initialize variable
        [System.Boolean]$IsDotless = $false
        [System.Boolean]$returnValue = $true
        [System.Boolean]$InvalidFlags = $false

        #check for invalid ExtendedProtectionFlags
        if (-not [System.String]::IsNullOrEmpty($Flags))
        {
            if ((StringArrayToLower $Flags).Contains("none") -and ($Flags.Count -gt 1))
            {
                Write-Verbose "Invalid combination of ExtendedProtectionFlags detected!"
                $InvalidFlags = $true
                $returnValue = $false
            }
        }

        #check for invalid formatted and Dotless SPNs
        if ((-not [System.String]::IsNullOrEmpty($SPNList)) -and (-not $InvalidFlags))
        {
            #check for Dotless SPN
            foreach ($S in $SPNList)
            {
                $Name = $S.Split('/')[1]
                if ([System.String]::IsNullOrEmpty($Name))
                {
                    Write-Verbose "Invalid SPN:$($S)"
                    break
                }
                else
                {
                    if (-not $Name.Contains('.'))
                    {
                        Write-Verbose -Message "Found Dotless SPN:$($Name)"
                        $IsDotless = $true
                        break
                    }
                }
            }
        }
    }
    Process
    {
        #check if AllowDotless is set in Flags
        if($IsDotless)
        {
            if([System.String]::IsNullOrEmpty($Flags))
            {
                Write-Verbose "AllowDotless SPN found, but Flags is NULL!"
                $returnValue = $false
            }
            else
            {
                if( -not (StringArrayToLower $Flags).Contains("allowdotlessspn"))
                {
                    Write-Verbose "AllowDotless is not found in Flags!"
                    $returnValue = $false
                }
            }
        }
    }
    End
    {
        $returnValue
    }
}

function Test-ExchDscObjectHasProperty
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Object]
        $Object,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyName
    )
    if (([bool]($Object.PSobject.Properties.name -contains $PropertyName)) -eq $true) {
        if ($null -ne $Object.$PropertyName) {
            return $true
        }
    }
    return $false
}

<#
    .SYNOPSIS
        This method is used to compare current and desired values for any DSC resource.

    .PARAMETER CurrentValues
        This is hash table of the current values that are applied to the resource.

    .PARAMETER DesiredValues
        This is a PSBoundParametersDictionary of the desired values for the resource.

    .PARAMETER ValuesToCheck
        This is a list of which properties in the desired values list should be checked.
        If this is empty then all values in DesiredValues are checked.
#>
function Test-ExchDscParameterState 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [HashTable]
        $CurrentValues,
        
        [Parameter(Mandatory = $true)]  
        [Object]
        $DesiredValues,

        [Parameter()] 
        [Array]
        $ValuesToCheck
    )

    $returnValue = $true

    if (($DesiredValues.GetType().Name -ne "HashTable") `
        -and ($DesiredValues.GetType().Name -ne "CimInstance") `
        -and ($DesiredValues.GetType().Name -ne "PSBoundParametersDictionary")) 
    {
        throw ("Property 'DesiredValues' in Test-ExchDscParameterState must be either a " + `
               "Hashtable or CimInstance. Type detected was $($DesiredValues.GetType().Name)")
    }

    if (($DesiredValues.GetType().Name -eq "CimInstance") -and ($null -eq $ValuesToCheck)) 
    {
        throw ("If 'DesiredValues' is a Hashtable then property 'ValuesToCheck' must contain " + `
               "a value")
    }

    if (($null -eq $ValuesToCheck) -or ($ValuesToCheck.Count -lt 1)) 
    {
        $KeyList = $DesiredValues.Keys
    } 
    else 
    {
        $KeyList = $ValuesToCheck
    }

    $KeyList | ForEach-Object -Process {
        if (($_ -ne "Verbose") -and ($_ -ne "InstallAccount")) 
        {
            if (($CurrentValues.ContainsKey($_) -eq $false) `
            -or ($CurrentValues.$_ -ne $DesiredValues.$_) `
            -or (($DesiredValues.ContainsKey($_) -eq $true) -and ($DesiredValues.$_.GetType().IsArray))) 
            {
                if ($DesiredValues.GetType().Name -eq "HashTable" -or `
                    $DesiredValues.GetType().Name -eq "PSBoundParametersDictionary") 
                {
                    
                    $CheckDesiredValue = $DesiredValues.ContainsKey($_)
                } 
                else 
                {
                    $CheckDesiredValue = Test-ExchDscObjectHasProperty $DesiredValues $_
                }

                if ($CheckDesiredValue) 
                {
                    $desiredType = $DesiredValues.$_.GetType()
                    $fieldName = $_
                    if ($desiredType.IsArray -eq $true) 
                    {
                        if (($CurrentValues.ContainsKey($fieldName) -eq $false) `
                        -or ($null -eq $CurrentValues.$fieldName)) 
                        {
                            Write-Verbose -Message ("Expected to find an array value for " + `
                                                    "property $fieldName in the current " + `
                                                    "values, but it was either not present or " + `
                                                    "was null. This has caused the test method " + `
                                                    "to return false.")
                            $returnValue = $false
                        } 
                        else 
                        {
                            $arrayCompare = Compare-Object -ReferenceObject $CurrentValues.$fieldName `
                                                           -DifferenceObject $DesiredValues.$fieldName
                            if ($null -ne $arrayCompare) 
                            {
                                Write-Verbose -Message ("Found an array for property $fieldName " + `
                                                        "in the current values, but this array " + `
                                                        "does not match the desired state. " + `
                                                        "Details of the changes are below.")
                                $arrayCompare | ForEach-Object -Process {
                                    Write-Verbose -Message "$($_.InputObject) - $($_.SideIndicator)"
                                }
                                $returnValue = $false
                            }
                        }
                    } 
                    else 
                    {
                        switch ($desiredType.Name) 
                        {
                            "String" {
                                if ([string]::IsNullOrEmpty($CurrentValues.$fieldName) `
                                -and [string]::IsNullOrEmpty($DesiredValues.$fieldName)) 
                                {} 
                                else 
                                {
                                    Write-Verbose -Message ("String value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int32" {
                                if (($DesiredValues.$fieldName -eq 0) `
                                -and ($null -eq $CurrentValues.$fieldName)) 
                                {} 
                                else 
                                {
                                    Write-Verbose -Message ("Int32 value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            "Int16" {
                                if (($DesiredValues.$fieldName -eq 0) `
                                -and ($null -eq $CurrentValues.$fieldName)) 
                                {} 
                                else 
                                {
                                    Write-Verbose -Message ("Int16 value for property " + `
                                                            "$fieldName does not match. " + `
                                                            "Current state is " + `
                                                            "'$($CurrentValues.$fieldName)' " + `
                                                            "and desired state is " + `
                                                            "'$($DesiredValues.$fieldName)'")
                                    $returnValue = $false
                                }
                            }
                            default {
                                Write-Verbose -Message ("Unable to compare property $fieldName " + `
                                                        "as the type ($($desiredType.Name)) is " + `
                                                        "not handled by the " + `
                                                        "Test-ExchDscParameterState cmdlet")
                                $returnValue = $false
                            }
                        }
                    }
                }            
            }
        } 
    }
    return $returnValue
}

Export-ModuleMember -Function *