<#
    .SYNOPSIS
        Automated unit integration for MSFT_xExchDatabaseAvailabilityGroup DSC Resource
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
        This module has the following additional requirements;
            * Requires that the ActiveDirectory module is installed
            * Requires that the DAG computer account has been precreated
            * Requires that the Failover-Clustering feature has been installed, and the machine has since been rebooted
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchDatabaseAvailabilityGroup'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

$adModule = Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue

if ($null -ne $adModule)
{
    if ($null -eq $dagName)
    {
        $dagName = Read-Host -Prompt 'Enter the name of the DAG to use for testing'
    }

    $compAccount = Get-ADComputer -Identity $dagName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount)
    {
        [System.String] $testDBName = 'TestDAGDB1'

        if ($exchangeInstalled)
        {
            # Get required credentials to use for the test
            $shellCredentials = Get-TestCredential

            # Get the Server FQDN for using in URL's
            if ($null -eq $serverFqdn)
            {
                $serverFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
            }

            if ($null -eq $secondDAGMember)
            {
                $secondDAGMember = Read-Host -Prompt 'Enter the host name of the second DAG member to use for testing, or press ENTER to skip.'

                # If they didn't enter anything, set to an empty string so we don't prompt again on a re-run of the test
                if ($null -eq $secondDAGMember)
                {
                    $secondDAGMember = ''
                }
            }

            # Make sure failover clustering is installed on both nodes. Start with this node.
            $fcNode1 = Get-WindowsFeature -Name Failover-Clustering -ComputerName $serverFqdn -ErrorAction SilentlyContinue

            if ($null -eq $fcNode1 -or !$fcNode1.Installed)
            {
                Write-Error -Message ('The Failover-Clustering role must be fully installed on' + $($serverFqdn) + `
                        'before the server can be added to the cluster. Skipping all DAG tests.')
                return
            }

            if (!([System.String]::IsNullOrEmpty($secondDAGMember)))
            {
                $fcNode2 = Get-WindowsFeature -Name Failover-Clustering -ComputerName $secondDAGMember -ErrorAction SilentlyContinue

                if ($null -eq $fcNode2 -or !$fcNode2.Installed)
                {
                    Write-Error -Message ('The Failover-Clustering role must be fully installed on' + $($secondDAGMember) + `
                            'before the server can be added to the cluster. Skipping tests that would utilize this DAG member.')

                    $secondDAGMember = ''
                }
            }

            while (([System.String]::IsNullOrEmpty($witness1)))
            {
                $witness1 = Read-Host -Prompt 'Enter the FQDN of the first File Share Witness for testing'
            }

            # Allow for the second witness to not be specified
            if ($null -eq $witness2)
            {
                $witness2 = Read-Host -Prompt 'Enter the FQDN of the second File Share Witness for testing, or press ENTER to skip.'

                # If they didn't enter anything, set to an empty string so we don't prompt again on a re-run of the test
                if ($null -eq $witness2)
                {
                    $witness2 = ''
                }
            }

            # Get Domain Controller
            [System.String] $dcToTestAgainst = Get-TestDomainController

            if ([System.String]::IsNullOrEmpty($dcToTestAgainst))
            {
                Write-Error -Message 'Unable to discover Domain Controller to use for DC specific tests.'
                return
            }

            # Remove the existing DAG
            Initialize-TestForDAG -ServerName @($env:COMPUTERNAME, $secondDAGMember) `
                -DAGName $dagName `
                -DatabaseName $testDBName `
                -ShellCredentials $shellCredentials

            Describe 'Test Creating and Modifying a DAG, adding DAG members, creating a DAG database, and adding database copies' {
                # Create a new DAG
                $dagTestParams = @{
                    Name                                 = $dagName
                    Credential                           = $shellCredentials
                    AutoDagAutoReseedEnabled             = $true
                    AutoDagDatabaseCopiesPerDatabase     = 2
                    AutoDagDatabaseCopiesPerVolume       = 2
                    AutoDagDatabasesRootFolderPath       = 'C:\ExchangeDatabases'
                    AutoDagDiskReclaimerEnabled          = $true
                    AutoDagTotalNumberOfServers          = 2
                    AutoDagTotalNumberOfDatabases        = 2
                    AutoDagVolumesRootFolderPath         = 'C:\ExchangeVolumes'
                    DatabaseAvailabilityGroupIpAddresses = '255.255.255.255'
                    DatacenterActivationMode             = 'DagOnly'
                    DomainController                     = $dcToTestAgainst
                    ManualDagNetworkConfiguration        = $true
                    NetworkCompression                   = 'Enabled'
                    NetworkEncryption                    = 'InterSubnetOnly'
                    ReplayLagManagerEnabled              = $true
                    SkipDagValidation                    = $true
                    WitnessDirectory                     = 'C:\Witness'
                    WitnessServer                        = $witness1
                }

                # Skip checking DatacenterActivationMode until we have DAG members
                $dagExpectedGetResults = @{
                    Name                             = $dagName
                    AutoDagAutoReseedEnabled         = $true
                    AutoDagDatabaseCopiesPerDatabase = 2
                    AutoDagDatabaseCopiesPerVolume   = 2
                    AutoDagDatabasesRootFolderPath   = 'C:\ExchangeDatabases'
                    AutoDagDiskReclaimerEnabled      = $true
                    AutoDagTotalNumberOfServers      = 2
                    AutoDagTotalNumberOfDatabases    = 2
                    AutoDagVolumesRootFolderPath     = 'C:\ExchangeVolumes'
                    ManualDagNetworkConfiguration    = $true
                    NetworkCompression               = 'Enabled'
                    NetworkEncryption                = 'InterSubnetOnly'
                    ReplayLagManagerEnabled          = $true
                    WitnessDirectory                 = 'C:\Witness'
                    WitnessServer                    = $witness1
                }

                if (!([System.String]::IsNullOrEmpty($witness2)))
                {
                    $dagTestParams.Add('AlternateWitnessServer', $witness2)
                    $dagTestParams.Add('AlternateWitnessDirectory', 'C:\Witness')
                    $dagExpectedGetResults.Add('AlternateWitnessServer', $witness2)
                    $dagExpectedGetResults.Add('AlternateWitnessDirectory', 'C:\Witness')
                }

                $serverVersion = Get-ExchangeVersionYear

                if ($serverVersion -in '2016', '2019')
                {
                    $dagTestParams.Add('FileSystem', 'ReFS')
                    $dagTestParams.Add('AutoDagAutoRedistributeEnabled', $true)
                    $dagTestParams.Add('PreferenceMoveFrequency', "$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())")
                    $dagExpectedGetResults.Add('FileSystem', 'ReFS')
                    $dagExpectedGetResults.Add('AutoDagAutoRedistributeEnabled', $true)
                    $dagExpectedGetResults.Add('PreferenceMoveFrequency', "$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())")
                }

                Test-TargetResourceFunctionality -Params $dagTestParams `
                    -ContextLabel 'Create the test DAG' `
                    -ExpectedGetResults $dagExpectedGetResults

                Test-ArrayContentsEqual -TestParams $dagTestParams `
                    -DesiredArrayContents $dagTestParams.DatabaseAvailabilityGroupIpAddresses `
                    -GetResultParameterName 'DatabaseAvailabilityGroupIpAddresses' `
                    -ContextLabel 'Verify DatabaseAvailabilityGroupIpAddresses' `
                    -ItLabel 'DatabaseAvailabilityGroupIpAddresses should contain two values'

                # Add this server as a DAG member
                Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue

                Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "MSFT_xExchDatabaseAvailabilityGroupMember" -ChildPath "MSFT_xExchDatabaseAvailabilityGroupMember.psm1"))))

                $dagMemberTestParams = @{
                    MailboxServer     = $env:COMPUTERNAME
                    Credential        = $shellCredentials
                    DAGName           = $dagName
                    DomainController  = $dcToTestAgainst
                    SkipDagValidation = $true
                }

                $dagMemberExpectedGetResults = @{
                    MailboxServer = $env:COMPUTERNAME
                    DAGName       = $dagName
                }

                Test-TargetResourceFunctionality -Params $dagMemberTestParams `
                    -ContextLabel 'Add first member to the test DAG' `
                    -ExpectedGetResults $dagMemberExpectedGetResults

                # Do second DAG member tests if a second member was specified
                if (([System.String]::IsNullOrEmpty($secondDAGMember)) -eq $false)
                {
                    # Add second DAG member
                    $dagMemberTestParams = @{
                        MailboxServer     = $secondDAGMember
                        Credential        = $shellCredentials
                        DAGName           = $dagName
                        DomainController  = $dcToTestAgainst
                        SkipDagValidation = $true
                    }

                    $dagMemberExpectedGetResults = @{
                        MailboxServer = $secondDAGMember
                        DAGName       = $dagName
                    }

                    Test-TargetResourceFunctionality -Params $dagMemberTestParams `
                        -ContextLabel 'Add second member to the test DAG' `
                        -ExpectedGetResults $dagMemberExpectedGetResults

                    # Test the DAG again, with props that only take effect once there are members
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

                    $dagExpectedGetResults.DatacenterActivationMode = 'DagOnly'

                    Test-TargetResourceFunctionality -Params $dagTestParams `
                        -ContextLabel 'Set remaining props on the test DAG' `
                        -ExpectedGetResults $dagExpectedGetResults

                    Test-ArrayContentsEqual -TestParams $dagTestParams `
                        -DesiredArrayContents $dagTestParams.DatabaseAvailabilityGroupIpAddresses `
                        -GetResultParameterName 'DatabaseAvailabilityGroupIpAddresses' `
                        -ContextLabel 'Verify DatabaseAvailabilityGroupIpAddresses' `
                        -ItLabel 'DatabaseAvailabilityGroupIpAddresses should contain two values'

                    # Create a new DAG database
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "MSFT_xExchMailboxDatabase" -ChildPath "MSFT_xExchMailboxDatabase.psm1"))))

                    $dagDBTestParams = @{
                        Name                = $testDBName
                        Credential          = $shellCredentials
                        AllowServiceRestart = $true
                        DatabaseCopyCount   = 2
                        DomainController    = $dcToTestAgainst
                        EdbFilePath         = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDBName)\$($testDBName).edb"
                        LogFolderPath       = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDBName)"
                        Server              = $env:COMPUTERNAME
                    }

                    $dagDBExpectedGetResults = @{
                        Name          = $testDBName
                        EdbFilePath   = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDBName)\$($testDBName).edb"
                        LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDBName)"
                        Server        = $env:COMPUTERNAME
                    }

                    Test-TargetResourceFunctionality -Params $dagDBTestParams `
                        -ContextLabel 'Create test database' `
                        -ExpectedGetResults $dagDBExpectedGetResults

                    # Add DB Copy
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "MSFT_xExchMailboxDatabaseCopy" -ChildPath "MSFT_xExchMailboxDatabaseCopy.psm1"))))

                    $dagDBCopyTestParams = @{
                        Identity                        = $testDBName
                        Credential                      = $shellCredentials
                        MailboxServer                   = $secondDAGMember
                        ActivationPreference            = 2
                        AdServerSettingsPreferredServer = $dcToTestAgainst
                        DomainController                = $dcToTestAgainst
                        ReplayLagTime                   = '7.00:00:00'
                        SeedingPostponed                = $false
                        TruncationLagTime               = '1.00:00:00'
                    }

                    $dagDBCopyExpectedGetResults = @{
                        Identity             = $testDBName
                        MailboxServer        = $secondDAGMember
                        ActivationPreference = 2
                        ReplayLagTime        = '7.00:00:00'
                        TruncationLagTime    = '1.00:00:00'
                    }

                    $serverVersion = Get-ExchangeVersionYear

                    if ($serverVersion -in '2016', '2019')
                    {
                        $dagDBCopyTestParams.Add('ReplayLagMaxDelay', '2.00:00:00')
                        $dagDBCopyExpectedGetResults.Add('ReplayLagMaxDelay', '2.00:00:00')
                    }

                    Test-TargetResourceFunctionality -Params $dagDBCopyTestParams `
                        -ContextLabel 'Add a database copy' `
                        -ExpectedGetResults $dagDBCopyExpectedGetResults

                    $dagDBCopyTestParams = @{
                        Identity                        = $testDBName
                        Credential                      = $shellCredentials
                        MailboxServer                   = $secondDAGMember
                        ActivationPreference            = 1
                        AdServerSettingsPreferredServer = $dcToTestAgainst
                        DomainController                = $dcToTestAgainst
                        ReplayLagTime                   = '0.00:00:00'
                        TruncationLagTime               = '0.00:00:00'
                    }

                    $dagDBCopyExpectedGetResults = @{
                        Identity             = $testDBName
                        MailboxServer        = $secondDAGMember
                        ActivationPreference = 1
                        ReplayLagTime        = '00:00:00'
                        TruncationLagTime    = '00:00:00'
                    }

                    if ($serverVersion -in '2016', '2019')
                    {
                        $dagDBCopyTestParams.Add('ReplayLagMaxDelay', '0.00:00:00')
                        $dagDBCopyExpectedGetResults.Add('ReplayLagMaxDelay', '00:00:00')
                    }

                    Test-TargetResourceFunctionality -Params $dagDBCopyTestParams `
                        -ContextLabel 'Change database copy settings' `
                        -ExpectedGetResults $dagDBCopyExpectedGetResults


                    #Remove test database before doing other add copy tests.
                    Remove-CopiesOfTestDatabase -DatabaseName $testDBName

                    $dagDBCopyTestParams.ActivationPreference = 4

                    $dagDBCopyExpectedGetResults.ActivationPreference = 2

                    Test-TargetResourceFunctionality -Params $dagDBCopyTestParams `
                        -ContextLabel 'Add a database copy with ActivationPreference higher than future copy count' `
                        -ExpectedGetResults $dagDBCopyExpectedGetResults `
                        -ExpectedTestResult $false

                    #Remove test database before doing other add copy tests.
                    Remove-CopiesOfTestDatabase -DatabaseName $testDBName

                    $dagDBCopyTestParams.ActivationPreference = 2
                    $dagDBCopyTestParams.SeedingPostponed = $true

                    $dagDBCopyExpectedGetResults.ActivationPreference = 2

                    Test-TargetResourceFunctionality -Params $dagDBCopyTestParams `
                        -ContextLabel 'Add a database copy with SeedingPostponed' `
                        -ExpectedGetResults $dagDBCopyExpectedGetResults `
                        -ExpectedTestResult $true
                }
            }
        }
        else
        {
            Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
        }
    }
    else
    {
        Write-Verbose -Message 'Tests in this file require that the computer account for the DAG is precreated'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS'
}
