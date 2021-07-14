<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchFrontendTransportService DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchFrontendTransportService'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    Describe 'Set and modify Frontend Transport Service configuration' {
    # Set configuration with default values
    $testParams = @{
         Identity                                = $env:computername
         Credential                              = $shellCredentials
         AllowServiceRestart                     = $true
         AgentLogEnabled                         = $true
         AgentLogMaxAge                          = '7.00:00:00'
         AgentLogMaxDirectorySize                = '250MB'
         AgentLogMaxFileSize                     = '10MB'
         AgentLogPath                            = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\AgentLog'
         ConnectivityLogEnabled                  = $true
         ConnectivityLogMaxAge                   = '30.00:00:00'
         ConnectivityLogMaxDirectorySize         = '1000MB'
         ConnectivityLogMaxFileSize              = '10MB'
         ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\Connectivity'
         DnsLogEnabled                           = $false
         DnsLogMaxAge                            = '7.00:00:00'
         DnsLogMaxDirectorySize                  = '100 MB'
         DnsLogMaxFileSize                       = '10 MB'
         DnsLogPath                              = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\DNS'
         ExternalDNSAdapterEnabled               = $true
         ExternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         ExternalDNSProtocolOption               = 'any'
         ExternalDNSServers                      = ''
         ExternalIPAddress                       = ''
         InternalDNSAdapterEnabled               = $true
         InternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         InternalDNSProtocolOption               = 'any'
         InternalDNSServers                      = ''
         IntraOrgConnectorProtocolLoggingLevel   = 'Verbose'
         MaxConnectionRatePerMinute              = '1200'
         ReceiveProtocolLogMaxAge                = '30.00:00:00'
         ReceiveProtocolLogMaxDirectorySize      = '250MB'
         ReceiveProtocolLogMaxFileSize           = '10 MB'
         ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive'
         RoutingTableLogMaxAge                   = '7.00:00:00'
         RoutingTableLogMaxDirectorySize         = '50 MB'
         RoutingTableLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\Routing'
         SendProtocolLogMaxAge                   = '30.00:00:00'
         SendProtocolLogMaxDirectorySize         = '250MB'
         SendProtocolLogMaxFileSize              = '10MB'
         SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend'
         TransientFailureRetryCount              = '6'
         TransientFailureRetryInterval           = '00:05:00'
    }

    $expectedGetResults = @{
         AgentLogEnabled                         = $true
         AgentLogMaxAge                          = '7.00:00:00'
         AgentLogMaxDirectorySize                = '250 MB (262,144,000 bytes)'
         AgentLogMaxFileSize                     = '10 MB (10,485,760 bytes)'
         AgentLogPath                            = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\AgentLog'
         ConnectivityLogEnabled                  = $true
         ConnectivityLogMaxAge                   = '30.00:00:00'
         ConnectivityLogMaxDirectorySize         = '1000 MB (1,048,576,000 bytes)'
         ConnectivityLogMaxFileSize              = '10 MB (10,485,760 bytes)'
         ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\Connectivity'
         DnsLogEnabled                           = $false
         DnsLogMaxAge                            = '7.00:00:00'
         DnsLogMaxDirectorySize                  = '100 MB (104,857,600 bytes)'
         DnsLogMaxFileSize                       = '10 MB (10,485,760 bytes)'
         DnsLogPath                              = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\DNS'
         ExternalDNSAdapterEnabled               = $true
         ExternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         ExternalDNSProtocolOption               = 'any'
         ExternalDNSServers                      = [System.String[]] @()
         ExternalIPAddress                       = ''
         InternalDNSAdapterEnabled               = $true
         InternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         InternalDNSProtocolOption               = 'any'
         InternalDNSServers                      = [System.String[]] @()
         IntraOrgConnectorProtocolLoggingLevel   = 'Verbose'
         MaxConnectionRatePerMinute              = '1200'
         ReceiveProtocolLogMaxAge                = '30.00:00:00'
         ReceiveProtocolLogMaxDirectorySize      = '250 MB (262,144,000 bytes)'
         ReceiveProtocolLogMaxFileSize           = '10 MB (10,485,760 bytes)'
         ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive'
         RoutingTableLogMaxAge                   = '7.00:00:00'
         RoutingTableLogMaxDirectorySize         = '50 MB (52,428,800 bytes)'
         RoutingTableLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\Routing'
         SendProtocolLogMaxAge                   = '30.00:00:00'
         SendProtocolLogMaxDirectorySize         = '250 MB (262,144,000 bytes)'
         SendProtocolLogMaxFileSize              = '10 MB (10,485,760 bytes)'
         SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpSend'
         TransientFailureRetryCount              = '6'
         TransientFailureRetryInterval           = '00:05:00'
    }

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set default Frontend Transport Service configuration' -ExpectedGetResults $expectedGetResults

     # Modify configuration
     $testParams.InternalDNSServers = '192.168.1.10'
     $testParams.ExternalDNSServers = '10.1.1.10'

     $expectedGetResults.InternalDNSServers = [System.String] @('192.168.1.10')
     $expectedGetResults.ExternalDNSServers = [System.String] @('10.1.1.10')

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Modify Transport Service configuration' -ExpectedGetResults $expectedGetResults

     # Modify configuration
     $testParams.InternalDNSServers = ''
     $testParams.ExternalDNSServers = ''

     $expectedGetResults.InternalDNSServers = [System.String[]] @()
     $expectedGetResults.ExternalDNSServers = [System.String[]] @()

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Revert Frontend Transport Service configuration' -ExpectedGetResults $expectedGetResults
     }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
