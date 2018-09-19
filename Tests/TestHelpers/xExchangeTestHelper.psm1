<#
    Function to be used within pester for end to end testing of Get/Set/Test-TargetResource
    Function first calls Set-TargetResource with provided parameters, then runs Get and Test-TargetResource,
    and ensures they match $ExpectedGetResults and $ExpectedTestResult
#>
function Test-TargetResourceFunctionality
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $Params,

        [Parameter()]
        [System.String]
        $ContextLabel,

        [Parameter()]
        [System.Collections.Hashtable]
        $ExpectedGetResults,

        [Parameter()]
        [System.Boolean]
        $ExpectedTestResult = $true
    )

    Context $ContextLabel {
        [System.Boolean]$testResult = Test-TargetResource @Params -Verbose

        Write-Verbose -Message "Test-TargetResource results before running Set-TargetResource: $testResult"

        Set-TargetResource @Params -Verbose

        [System.Collections.Hashtable]$getResult = Get-TargetResource @Params -Verbose
        [System.Boolean]$testResult = Test-TargetResource @Params -Verbose

        #The ExpectedGetResults are $null, so let's check that what we got back is $null
        if ($null -eq $ExpectedGetResults)
        {
            It 'Get-TargetResource: Should Be Null' {
                $getResult | Should BeNullOrEmpty
            }
        }
        else
        {
            <#
                Check the members of the Get-TargetResource results and make sure the result types
                match those of the function parameters
            #>
            $getTargetResourceCommand = Get-Command Get-TargetResource

            It "Only 1 Get-TargetResource function is loaded" {
                $getTargetResourceCommand.Count -eq 1 | Should Be $true
            }

            if ($getTargetResourceCommand.Count -eq 1)
            {
                foreach ($getTargetResourceParam in $getTargetResourceCommand.Parameters.Keys | Where-Object {$getResult.ContainsKey($_)})
                {
                    $getResultMemberType = '$null'

                    if ($null -ne ($getResult[$getTargetResourceParam]))
                    {
                        $getResultMemberType = $getResult[$getTargetResourceParam].GetType().ToString()
                    }

                    It "Get-TargetResource: Parameter '$getTargetResourceParam' expects return type: '$($getTargetResourceCommand.Parameters[$getTargetResourceParam].ParameterType.ToString())'. Actual return type: '$getResultMemberType'" {
                        ($getTargetResourceCommand.Parameters[$getTargetResourceParam].ParameterType.ToString()) -eq $getResultMemberType | Should Be $true
                    }
                }
            }

            #Test each individual key in $ExpectedGetResult to see if they exist, and if the expected value matches
            foreach ($key in $ExpectedGetResults.Keys)
            {
                $getContainsKey = $getResult.ContainsKey($key)

                It "Get-TargetResource: Contains Key: $($key)" {
                    $getContainsKey | Should Be $true
                }

                if ($getContainsKey)
                {
                    if ($getResult.ContainsKey($key))
                    {
                        switch ((Get-Command Get-TargetResource).Parameters[$key].ParameterType)
                        {
                            ([System.String[]])
                            {
                                $getValueMatchesForKey = Compare-ArrayContent -Array1 $getResult[$key] -Array2 $ExpectedGetResults[$key]
                            }
                            ([System.Management.Automation.PSCredential])
                            {
                                $getValueMatchesForKey = $getResult[$key].UserName -like $ExpectedGetResults[$key].UserName
                            }
                            default
                            {
                                $getValueMatchesForKey = ($getResult[$key] -eq $ExpectedGetResults[$key])
                            }
                        }
                    }
                    else
                    {
                        $getValueMatchesForKey = $false
                    }

                    It "Get-TargetResource: Value Matches for Key: $($key)" {
                        $getValueMatchesForKey | Should Be $true
                    }
                }
            }
        }

        #Test the Test-TargetResource results
        It 'Test-TargetResource' {
            $testResult | Should Be $ExpectedTestResult
        }
    }
}

function Test-ArrayContentsEqual
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $TestParams,

        [Parameter()]
        [System.String[]]
        $DesiredArrayContents,

        [Parameter()]
        [System.String]
        $GetResultParameterName,

        [Parameter()]
        [System.String]
        $ContextLabel,

        [Parameter()]
        [System.String]
        $ItLabel
    )

    Context $ContextLabel {
        [System.Collections.Hashtable]$getResult = Get-TargetResource @TestParams

        It $ItLabel {
            Compare-ArrayContent -Array1 $DesiredArrayContents -Array2 $getResult."$($GetResultParameterName)" -IgnoreCase | Should Be $true
        }
    }
}

function Test-Array2ContainsArray1
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $TestParams,

        [Parameter()]
        [System.String[]]
        $DesiredArrayContents,

        [Parameter()]
        [System.String]
        $GetResultParameterName,

        [Parameter()]
        [System.String]
        $ContextLabel,

        [Parameter()]
        [System.String]
        $ItLabel
    )

    Context $ContextLabel {
        [System.Collections.Hashtable]$getResult = Get-TargetResource @TestParams

        It $ItLabel {
            Array2ContainsArray1Contents -Array1 $DesiredArrayContents -Array2 $getResult."$($GetResultParameterName)" -IgnoreCase | Should Be $true
        }
    }
}

#Creates a test OAB for DSC, or sees if it exists. If it is created or exists, return the name of the OAB.
function Get-TestOfflineAddressBook
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $ShellCredentials
    )

    [System.String]$testOabName = 'Offline Address Book (DSC Test)'

    GetRemoteExchangeSession -Credential $ShellCredentials -CommandsToLoad '*-OfflineAddressBook'

    if ($null -eq (Get-OfflineAddressBook -Identity $testOabName -ErrorAction SilentlyContinue))
    {
        Write-Verbose -Message "Test OAB does not exist. Creating OAB with name '$testOabName'."

        $testOab = New-OfflineAddressBook -Name $testOabName -AddressLists '\'

        if ($null -eq $testOab)
        {
            throw 'Failed to create test OAB.'
        }
    }

    return $testOabName
}

#Removes the test DAG if it exists, and any associated databases
function Initialize-TestForDAG
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $ServerName,

        [Parameter()]
        [System.String]
        $DAGName,

        [Parameter()]
        [System.String]
        $DatabaseName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $ShellCredentials
    )

    Write-Verbose -Message 'Cleaning up test DAG and related resources'

    GetRemoteExchangeSession -Credential $ShellCredentials -CommandsToLoad '*-MailboxDatabase',`
                                                                                  '*-DatabaseAvailabilityGroup',`
                                                                                  'Remove-DatabaseAvailabilityGroupServer',`
                                                                                  'Get-MailboxDatabaseCopyStatus',`
                                                                                  'Remove-MailboxDatabaseCopy'

    $existingDB = Get-MailboxDatabase -Identity "$($DatabaseName)" -Status -ErrorAction SilentlyContinue

    #First remove the test database copies
    if ($null -ne $existingDB)
    {
        Get-MailboxDatabaseCopyStatus -Identity "$($DatabaseName)" | Where-Object -FilterScript {
            $existingDB.MountedOnServer.ToLower().Contains($_.MailboxServer.ToLower()) -eq $false
        } | Remove-MailboxDatabaseCopy -Confirm:$false
    }

    #Now remove the actual DB's
    Get-MailboxDatabase | Where-Object -FilterScript {
        $_.Name -like "$($DatabaseName)"
    } | Remove-MailboxDatabase -Confirm:$false

    #Remove the files
    foreach ($server in $ServerName)
    {
        Get-ChildItem -LiteralPath "\\$($server)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($DatabaseName)" `
                      -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    }

    #Last remove the test DAG
    $dag = Get-DatabaseAvailabilityGroup -Identity "$($DAGName)" -ErrorAction SilentlyContinue

    if ($null -ne $dag)
    {
        Set-DatabaseAvailabilityGroup -Identity "$($DAGName)" -DatacenterActivationMode Off

        foreach ($server in $dag.Servers)
        {
            Remove-DatabaseAvailabilityGroupServer -MailboxServer "$($server.Name)" -Identity "$($DAGName)" -Confirm:$false
        }

        Remove-DatabaseAvailabilityGroup -Identity "$($DAGName)" -Confirm:$false
    }

    if ($null -ne (Get-DatabaseAvailabilityGroup -Identity "$($DAGName)" -ErrorAction SilentlyContinue))
    {
        throw 'Failed to remove test DAG'
    }

    #Disable the DAG computer account
    $compAccount = Get-ADComputer -Identity $DAGName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount -and $compAccount.Enabled -eq $true)
    {
        $compAccount | Disable-ADAccount
    }

    Write-Verbose -Message 'Finished cleaning up test DAG and related resources'
}

<#
    .SYNOPSIS
        Prompts for credentials to use for Exchange tests and returns the
        credentials as a PSCredential object. Only prompts for credentials
        on the first call to the function.
#>
function Get-TestCredential
{
    # Suppressing this rule so that Exchange credentials can be re-used across multiple test scripts
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCredential])]
    param()

    if ($null -eq $Global:TestCredential)
    {
        [PSCredential]$Global:TestCredential = Get-Credential -Message 'Enter credentials for connecting a Remote PowerShell session to Exchange'
    }

    return $Global:TestCredential
}

<#
    .SYNOPSIS
        Gets all configured Accepted Domains, and returns the Domain name of
        the first retrieved Accepted Domain. Throws an exception if no
        Accepted Domains are configured.
#>
function Get-TestAcceptedDomainName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    [System.Object[]] $acceptedDomains = Get-AcceptedDomain

    if ($acceptedDomains.Count -gt 0)
    {
        return $acceptedDomains[0].DomainName.ToString()
    }
    else
    {
        throw 'One or more Accepted Domains must be configured for tests to function.'
    }
}

<#
    .SYNOPSIS
        Returns a Mailbox object corresponding to a DSC Test Mailbox. Creates
        the Mailbox if it does not already exist.
#>
function Get-DSCTestMailbox
{
    [CmdletBinding()]
    [OutputType([Microsoft.Exchange.Data.Directory.Management.Mailbox])]
    param()

    $testMailboxName = 'DSCTestMailbox'

    $testDomain = Get-TestAcceptedDomainName
    $testCreds = Get-TestCredential

    $testMailbox = Get-Mailbox $testMailboxName -ErrorAction SilentlyContinue
    $primarySMTP = "$testMailboxName@$testDomain"
    $secondarySMTP = "$($testMailboxName)2@$testDomain"
    [System.Object[]] $dbsOnServer = Get-MailboxDatabase -Server $env:COMPUTERNAME -ErrorAction SilentlyContinue

    $changedMailbox = $false

    # Create the test mailbox if it doesn't exist
    if ($null -eq $testMailbox)
    {
        Write-Verbose -Message "Creating test mailbox: $testMailboxName"

        $newMailboxParams = @{
            Name               = $testMailboxName
            PrimarySmtpAddress = $primarySMTP
            UserPrincipalName  = $primarySMTP
            Password           = $testCreds.Password
        }

        if ($dbsOnServer.Count -gt 0)
        {
            $newMailboxParams.Add('Database',$dbsOnServer[0].Name)
        }

        $testMailbox = New-Mailbox @newMailboxParams

        if ($null -eq $testMailbox)
        {
            throw 'Failed to create test mailbox'
        }
    }

    # Set the test mailbox primary SMTP if not correct
    if ($testMailbox.PrimarySmtpAddress.Address -notlike $primarySMTP)
    {
        Write-Verbose -Message "Changing primary SMTP on test mailbox: $testMailboxName"

        $testMailbox | Set-Mailbox -PrimarySmtpAddress $primarySMTP

        $changedMailbox = $true
    }

    # Add the secondary SMTP if necessary
    if (($testMailbox.EmailAddresses | Where-Object {$_.AddressString -like $secondarySMTP}).Count -eq 0)
    {
        Write-Verbose -Message "Adding secondary SMTP on test mailbox: $testMailboxName"

        $testMailbox | Set-Mailbox -EmailAddresses @{add=$secondarySMTP}

        $changedMailbox = $true
    }

    # Get the mailbox one more time so we have updated properties on it
    if ($changedMailbox)
    {
        $testMailbox = Get-Mailbox $testMailboxName
    }

    return $testMailbox
}

<#
    .SYNOPSIS
        Returns a MailUser object corresponding to a DSC Test MailUser. Creates
        the MailUser if it does not already exist.
#>
function Get-DSCTestMailUser
{
    [CmdletBinding()]
    [OutputType([Microsoft.Exchange.Data.Directory.Management.MailUser])]
    param()

    $testMailUserName = 'DSCTestMailUser'

    $testMailUser = Get-MailUser $testMailUserName -ErrorAction SilentlyContinue
    $primarySMTP = "$testMailUserName@contoso.local"

    $changedMailUser = $false

    # Create the test MailUser if it doesn't exist
    if ($null -eq $testMailUser)
    {
        Write-Verbose -Message "Creating test mail user: $testMailUserName"

        $newMailUserParams = @{
            Name                 = $testMailUserName
            ExternalEmailAddress = $primarySMTP
        }

        $testMailUser = New-MailUser @newMailUserParams

        if ($null -eq $testMailUser)
        {
            throw 'Failed to create test MailUser'
        }
    }

    # Set the test MailUser primary SMTP if not correct
    if ($testMailUser.ExternalEmailAddress.AddressString -notlike $primarySMTP)
    {
        Write-Verbose -Message "Changing ExternalEmailAddress on test mail user: $testMailboxName"

        $testMailUser | Set-MailUser -ExternalEmailAddress $primarySMTP

        $changedMailUser = $true
    }

    # Get the MailUser one more time so we have updated properties on it
    if ($changedMailUser)
    {
        $testMailUser = Get-MailUser $testMailUserName
    }

    return $testMailUser
}

<#
    .SYNOPSIS
        Returns a MailContact object corresponding to a DSC Test MailContact.
        Creates the MailContact if it does not already exist.
#>
function Get-DSCTestMailContact
{
    [CmdletBinding()]
    [OutputType([Microsoft.Exchange.Data.Directory.Management.MailContact])]
    param()

    $testMailContactName = 'DSCTestMailContact'

    $testMailContact = Get-MailContact $testMailContactName -ErrorAction SilentlyContinue
    $primarySMTP = "$testMailContactName@contoso.local"

    $changedMailContact = $false

    # Create the test MailContact if it doesn't exist
    if ($null -eq $testMailContact)
    {
        Write-Verbose -Message "Creating test mail contact: $testMailContactName"

        $newMailContactParams = @{
            Name                 = $testMailContactName
            ExternalEmailAddress = $primarySMTP
        }

        $testMailContact = New-MailContact @newMailContactParams

        if ($null -eq $testMailContact)
        {
            throw 'Failed to create test MailContact'
        }
    }

    # Set the test MailContact primary SMTP if not correct
    if ($testMailContact.ExternalEmailAddress.AddressString -notlike $primarySMTP)
    {
        Write-Verbose -Message "Changing ExternalEmailAddress on test mail contact: $testMailContactName"

        $testMailContact | Set-MailContact -ExternalEmailAddress $primarySMTP

        $changedMailContact = $true
    }

    # Get the MailContact one more time so we have updated properties on it
    if ($changedMailContact)
    {
        $testMailContact = Get-MailContact $testMailContactName
    }

    return $testMailContact
}

Export-ModuleMember -Function *
