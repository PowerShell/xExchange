<#
    .SYNOPSIS
        Function to be used within pester for end to end testing of
        Get/Set/Test-TargetResource. Function first calls Set-TargetResource
        with provided parameters, then runs Get and Test-TargetResource, and
        ensures they match $ExpectedGetResults and $ExpectedTestResult.

    .PARAMETER Params
        The Parameters to pass when calling Get/Set/Test-TargetResource.

    .PARAMETER ContextLabel
        The label to use within the Context block of tests.

    .PARAMETER ExpectedGetResults
        A hashtable containing the expected return values from
        Get-TargetResource.

    .PARAMETER ExpectedTestResult
        The expected return value from Test-TargetResource.

    .PARAMETER Sleep
        Specifies sleep time in seconds between calling Set-TargetResource and Test-TargetResource functions.
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
        [System.Collections.Hashtable]
        $GetParams,

        [Parameter()]
        [System.String]
        $ContextLabel,

        [Parameter()]
        [System.Collections.Hashtable]
        $ExpectedGetResults,

        [Parameter()]
        [System.Boolean]
        $ExpectedTestResult = $true,

        [Parameter()]
        [System.Int32]
        $Sleep
    )

    Context $ContextLabel {
        $addedVerbose = $false

        if ($null -eq ($Params.Keys | Where-Object -FilterScript { $_ -like 'Verbose' }))
        {
            $Params.Add('Verbose', $true)
            $addedVerbose = $true
        }
        if ($null -eq $GetParams)
        {
            $GetParams = $Params
        }

        [System.Boolean] $testResult = Test-TargetResource @Params

        Write-Verbose -Message "Test-TargetResource results before running Set-TargetResource: $testResult"

        Set-TargetResource @Params

        if ($Sleep)
        {
            Start-Sleep -Seconds $Sleep
        }

        [System.Collections.Hashtable] $getResult = Get-TargetResource @GetParams
        [System.Boolean] $testResult = Test-TargetResource @Params

        # The ExpectedGetResults are $null, so let's check that what we got back is $null
        if ($null -eq $ExpectedGetResults)
        {
            It 'Get-TargetResource: Should Be Null' {
                $getResult | Should -BeNullOrEmpty
            }
        }
        else
        {
            Test-CommonGetTargetResourceFunctionality -GetResult $getResult

            # Test each individual key in $ExpectedGetResult to see if they exist, and if the expected value matches
            foreach ($key in $ExpectedGetResults.Keys)
            {
                $getContainsKey = $getResult.ContainsKey($key)
                $getSetValue = ""
                $getExpectedValue = ""
                It "Get-TargetResource: Contains Key: $($key)" {
                    $getContainsKey | Should -Be $true
                }

                if ($getContainsKey)
                {
                    if ($getResult.ContainsKey($key))
                    {
                        switch ((Get-Command Set-TargetResource).Parameters[$key].ParameterType)
                        {
                            ([System.String[]])
                            {
                                $getValueMatchesForKey = Compare-ArrayContent -Array1 $getResult[$key] -Array2 $ExpectedGetResults[$key]
                            }
                            ([System.Management.Automation.PSCredential])
                            {
                                $getValueMatchesForKey = $getResult[$key].UserName -like $ExpectedGetResults[$key].UserName
                            }
                            ([Microsoft.Management.Infrastructure.CimInstance[]])
                            {
                                $getValueMatchesForKey = Test-CimArrayContainsSubArray -Array $getResult[$key] -SubArray $ExpectedGetResults[$key]
                            }
                            default
                            {
                                $getSetValue = $getResult[$key]
                                $getExpectedValue = $ExpectedGetResults[$key]
                                $getValueMatchesForKey = ($getResult[$key] -eq $ExpectedGetResults[$key])
                            }
                        }
                    }
                    else
                    {
                        $getValueMatchesForKey = $false
                    }
                    It "Get-TargetResource: Value Matches for Key: $($key) value: $getSetValue expected: $getExpectedValue" {
                        $getValueMatchesForKey | Should -Be $true
                    }
                }
            }
        }

        # Test the Test-TargetResource results
        It 'Test-TargetResource' {
            $testResult | Should -Be $ExpectedTestResult
        }

        if ($addedVerbose)
        {
            $Params.Remove('Verbose')
        }
    }
}

<#
    .SYNOPSIS
        Runs Get-TargetTesource, or takes the results of a previous
        Get-TargetResource execution, and performs common tests against the
        results. The function must be provided either the results from a
        previous Get-TargetResource execution, or the parameters to send to
        Get-TargetResource, but not both. If neither parameter is specified,
        or both parameters are specified, the function will throw an exception.

    .PARAMETER GetResult
        The results of a previous Get-TargetResource execution.

    .PARAMETER GetTargetResourceParams
        The parameters that should be passed to Get-TargetResource.
#>
function Test-CommonGetTargetResourceFunctionality
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $GetResult,

        [Parameter()]
        [System.Collections.Hashtable]
        $GetTargetResourceParams
    )

    if (($GetResult.Count -eq 0 -and $GetTargetResourceParams.Count -eq 0) -or ($GetResult.Count -gt 0 -and $GetTargetResourceParams.Count -gt 0))
    {
        throw 'Either the GetResult or GetTargetResourceParams parameters must be specified with non-empty hashtables, but not both.'
    }

    if ($GetResult.Count -eq 0)
    {
        $GetResult = Get-TargetResource @GetTargetResourceParams
    }

    It 'Should return a hashtable of properties' {
        $GetResult | Should -Be -Not $null
    }

    $getTargetResourceCommand = Get-Command Get-TargetResource

    It 'Only 1 Get-TargetResource function should be loaded' {
        $getTargetResourceCommand.Count -eq 1 | Should -Be $true
    }

    if ($getTargetResourceCommand.Count -eq 1)
    {
        foreach ($getTargetResourceParam in $getTargetResourceCommand.Parameters.Keys | Where-Object -FilterScript { $GetResult.ContainsKey($_) })
        {
            $getResultMemberType = '$null'

            if ($null -ne ($GetResult[$getTargetResourceParam]))
            {
                $getResultMemberType = $GetResult[$getTargetResourceParam].GetType().ToString()
            }

            It "Should return a value of type '$($getTargetResourceCommand.Parameters[$getTargetResourceParam].ParameterType.ToString())' for hashtable member '$getTargetResourceParam'. Actual return type: '$getResultMemberType'" {
                ($getTargetResourceCommand.Parameters[$getTargetResourceParam].ParameterType.ToString()) -eq $getResultMemberType | Should -Be $true
            }
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
        [System.Collections.Hashtable] $getResult = Get-TargetResource @TestParams

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
        [System.Collections.Hashtable] $getResult = Get-TargetResource @TestParams

        It $ItLabel {
            Test-ArrayElementsInSecondArray -Array1 $DesiredArrayContents -Array2 $getResult."$GetResultParameterName" -IgnoreCase | Should Be $true
        }
    }
}

# Creates a test OAB for DSC, or sees if it exists. If it is created or exists, return the name of the OAB.
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

    [System.String] $testOabName = 'Offline Address Book (DSC Test)'

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

# Removes the test DAG if it exists, and any associated databases
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

    Get-RemoteExchangeSession -Credential $ShellCredentials -CommandsToLoad '*-MailboxDatabase', `
        '*-DatabaseAvailabilityGroup', `
        'Remove-DatabaseAvailabilityGroupServer', `
        'Get-MailboxDatabaseCopyStatus', `
        'Remove-MailboxDatabaseCopy'

    $existingDB = Get-MailboxDatabase -Identity "$($DatabaseName)" -Status -ErrorAction SilentlyContinue

    # First remove the test database copies
    Remove-CopiesOfTestDatabase -DatabaseName $DatabaseName

    # Now remove the actual DB's
    Remove-TestDatabase -DatabaseName $DatabaseName -ServerName $ServerName

    # Last remove the test DAG
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

    # Disable the DAG computer account
    $compAccount = Get-ADComputer -Identity $DAGName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount -and $compAccount.Enabled -eq $true)
    {
        $compAccount | Disable-ADAccount
    }

    Write-Verbose -Message 'Finished cleaning up test DAG and related resources'
}

<#
    .SYNOPSIS
        Removes all copies of the given Mailbox Database that are not currently
        mounted.

    .PARAMETER DatabaseName
        The name of the Database to remove copies from.
#>
function Remove-CopiesOfTestDatabase
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $DatabaseName
    )

    $existingDB = Get-MailboxDatabase -Identity "$($DatabaseName)" -Status -ErrorAction SilentlyContinue

    # First remove the test database copies
    if ($null -ne $existingDB)
    {
        Get-MailboxDatabaseCopyStatus -Identity "$($DatabaseName)" | Where-Object -FilterScript {
            $_.Status -notlike 'Mounted'
        } | Remove-MailboxDatabaseCopy -Confirm:$false
}
}

<#
    .SYNOPSIS
        Removes the specified Mailbox Database, as well as associated database
        files from the specified Servers.

    .PARAMETER ServerName
        The servers to remove database files from.

    .PARAMETER DatabaseName
        The name of the Database to remove.
#>
function Remove-TestDatabase
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $ServerName,

        [Parameter()]
        [System.String]
        $DatabaseName
    )

    Get-MailboxDatabase | Where-Object -FilterScript {
        $_.Name -like "$($DatabaseName)"
    } | Remove-MailboxDatabase -Confirm:$false

# Remove the files
foreach ($server in $ServerName)
{
    Get-ChildItem -LiteralPath "\\$($server)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($DatabaseName)" `
        -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
}
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
        [PSCredential] $Global:TestCredential = Get-Credential -Message 'Enter credentials for connecting a Remote PowerShell session to Exchange'
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
            $newMailboxParams.Add('Database', $dbsOnServer[0].Name)
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
    if (($testMailbox.EmailAddresses | Where-Object { $_.AddressString -like $secondarySMTP }).Count -eq 0)
    {
        Write-Verbose -Message "Adding secondary SMTP on test mailbox: $testMailboxName"

        $testMailbox | Set-Mailbox -EmailAddresses @{add = $secondarySMTP }

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

<#
    .SYNOPSIS
        Returns the FQDN of the first domain controller discovered using
        Get-ADDomainController.
#>
function Get-TestDomainController
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param()

    $dcToTestAgainst = ''

    [System.Object[]] $foundDCs = Get-ADDomainController

    if ($foundDCs.Count -gt 0)
    {
        [System.String] $dcToTestAgainst = $foundDCs[0].HostName
    }

    return $dcToTestAgainst
}

function Invoke-TestSetup
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $DSCModuleName,

        [Parameter()]
        [System.String]
        $DSCResourceName
    )
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $splat = @{
        DSCModuleName = $DSCModuleName
        DscResource   = $DSCResourceName
        ResourceType  = 'Mof'
        TestType      = 'Unit'
    }

    Initialize-TestEnvironment @splat
}

function Test-CimArrayContainsSubArray
{
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Array,

        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $SubArray
    )

    foreach ($subItem in $SubArray)
    {
        $equalFound = $false
        foreach ($item in $Array)
        {
            if (-not (Compare-Object -DifferenceObject $subItem -ReferenceObject $item -Property Key, Value))
            {
                # Found a match, skip to next $subItem
                $equalFound = $true
                break
            }
            if (Test-ArrayElementsInSecondArray -Array1 $subItem.value.Split(',') -Array2 $item.Value.Split(',') -IgnoreCase)
            {
                # Found a match, skip to next $subItem
                $equalFound = $true
                break
            }
        }

        if ($equalFound -eq $false)
        {
            return $false
        }
    }

    return $true
}
Export-ModuleMember -Function *

