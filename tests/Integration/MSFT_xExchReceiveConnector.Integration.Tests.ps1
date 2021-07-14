<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchReceiveConnector DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchReceiveConnector'
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

    Describe 'Set and modify a Receive Connector' {
        # Set configuration with default values

        $extendedRightAllowEntries = $(New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration  -ClientOnly -Property @{
                Key   = 'NT AUTHORITY\ANONYMOUS LOGON'
                Value = 'Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-Bypass-Anti-Spam'
            }
        )
        $testParams = @{
            Identity                                = "$($env:computername)\AnonymousRelay $($env:computername)"
            Credential                              = $shellCredentials
            Ensure                                  = 'Present'
            ExtendedRightAllowEntries               = $extendedRightAllowEntries
            AdvertiseClientSettings                 = $false
            AuthMechanism                           = 'Tls', 'ExternalAuthoritative'
            Banner                                  = '220 Pester'
            BareLinefeedRejectionEnabled            = $false
            BinaryMimeEnabled                       = $true
            Bindings                                = '192.168.0.100:25'
            ChunkingEnabled                         = $true
            Comment                                 = 'Connector for relaying'
            ConnectionInactivityTimeout             = '00:05:00'
            ConnectionTimeout                       = '00:10:00'
            DefaultDomain                           = ''
            DeliveryStatusNotificationEnabled       = $true
            DomainSecureEnabled                     = $false
            EightBitMimeEnabled                     = $true
            EnableAuthGSSAPI                        = $false
            Enabled                                 = $true
            EnhancedStatusCodesEnabled              = $true
            ExtendedProtectionPolicy                = 'none'
            Fqdn                                    = "$($env:computername).exp.com"
            LongAddressesEnabled                    = $false
            MaxHeaderSize                           = '128KB'
            MaxHopCount                             = '60'
            MaxInboundConnection                    = '5000'
            MaxInboundConnectionPercentagePerSource = '100'
            MaxInboundConnectionPerSource           = '50'
            MaxLocalHopCount                        = '12'
            MaxLogonFailures                        = '3'
            MaxMessageSize                          = '35MB'
            MaxProtocolErrors                       = '5'
            MaxRecipientsPerMessage                 = '5000'
            MessageRateLimit                        = 'Unlimited'
            MessageRateSource                       = 'IPAddress'
            OrarEnabled                             = $false
            PermissionGroups                        = 'AnonymousUsers', 'ExchangeServers'
            PipeliningEnabled                       = $true
            ProtocolLoggingLevel                    = 'Verbose'
            RemoteIPRanges                          = '192.16.7.99'
            RequireEHLODomain                       = $false
            RequireTLS                              = $false
            ServiceDiscoveryFqdn                    = ''
            SizeEnabled                             = 'EnabledwithoutValue'
            SuppressXAnonymousTls                   = $false
            TarpitInterval                          = '00:00:00'
            TlsCertificateName                      = $null
            TlsDomainCapabilities                   = 'contoso.com:AcceptOorgProtocol'
            TransportRole                           = 'FrontendTransport'
            Usage                                   = 'Custom'
        }

        $getParams = @{
            Identity   = "$($env:computername)\AnonymousRelay $($env:computername)"
            Credential = $shellCredentials
            Ensure     = 'Present'
        }

        $expectedGetResults = @{
            ExtendedRightAllowEntries               = $extendedRightAllowEntries
            AdvertiseClientSettings                 = $false
            AuthMechanism                           = 'Tls', 'ExternalAuthoritative'
            Banner                                  = '220 Pester'
            BareLinefeedRejectionEnabled            = $false
            BinaryMimeEnabled                       = $true
            Bindings                                = '192.168.0.100:25'
            ChunkingEnabled                         = $true
            Comment                                 = 'Connector for relaying'
            ConnectionInactivityTimeout             = '00:05:00'
            ConnectionTimeout                       = '00:10:00'
            DefaultDomain                           = ''
            # DomainController                        = ''
            DeliveryStatusNotificationEnabled       = $true
            DomainSecureEnabled                     = $false
            EightBitMimeEnabled                     = $true
            EnableAuthGSSAPI                        = $false
            Enabled                                 = $true
            EnhancedStatusCodesEnabled              = $true
            ExtendedProtectionPolicy                = 'none'
            Fqdn                                    = "$($env:computername).exp.com"
            LongAddressesEnabled                    = $false
            MaxHeaderSize                           = '128 KB (131,072 bytes)'
            MaxHopCount                             = '60'
            MaxInboundConnection                    = '5000'
            MaxInboundConnectionPercentagePerSource = '100'
            MaxInboundConnectionPerSource           = '50'
            MaxLocalHopCount                        = '12'
            MaxLogonFailures                        = '3'
            MaxMessageSize                          = '35 MB (36,700,160 bytes)'
            MaxProtocolErrors                       = '5'
            MaxRecipientsPerMessage                 = '5000'
            MessageRateLimit                        = 'Unlimited'
            MessageRateSource                       = 'IPAddress'
            OrarEnabled                             = $false
            PermissionGroups                        = [System.String[]] @('AnonymousUsers', 'ExchangeServers', 'Custom')
            PipeliningEnabled                       = $true
            ProtocolLoggingLevel                    = 'Verbose'
            RemoteIPRanges                          = '192.16.7.99'
            RequireEHLODomain                       = $false
            RequireTLS                              = $false
            ServiceDiscoveryFqdn                    = ''
            SizeEnabled                             = 'EnabledwithoutValue'
            SuppressXAnonymousTls                   = $false
            TarpitInterval                          = '00:00:00'
            TlsCertificateName                      = ''
            TlsDomainCapabilities                   = 'contoso.com:AcceptOorgProtocol'
            TransportRole                           = 'FrontendTransport'
        }
        # -MaxAcknowledgementDelay
        # This parameter isn't used by Microsoft Exchange Server 2016. It's only used by Microsoft Exchange 2010 servers in a coexistence environment.
        if ($serverVersion -in '2010')
        {
            $testParams.Add('MaxAcknowledgementDelay', '00:00:00')
            $expectedGetResults.Add('MaxAcknowledgementDelay', '00:00:00')
        }

        Test-TargetResourceFunctionality -Params $testParams -GetParams $getParams -ContextLabel 'Create Receive Connector' -ExpectedGetResults $expectedGetResults

        # Modify configuration
        $extendedRightDenyEntries = $(New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration `
                -Property @{Key = "$($env:USERDOMAIN)\Domain Users"; Value = 'ms-Exch-Bypass-Anti-Spam' } -ClientOnly)

        $testParams.ExtendedRightDenyEntries = $extendedRightDenyEntries
        $expectedGetResults.ExtendedRightDenyEntries = $extendedRightDenyEntries

        Test-TargetResourceFunctionality -Params $testParams -GetParams $getParams -ContextLabel 'Modify Receive Connector' -ExpectedGetResults $expectedGetResults

        # Modify configuration
        $testParams.Ensure = 'Absent'
        $getParams.Ensure = 'Absent'

        # Here they try to add a new expectResult but, the real test are change one attribute from the expectresult
        # $expectedGetResults = @{
        #     Ensure = 'Absent'
        # }
        # I change to this
        $expectedGetResults.Ensure = 'Absent'
        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Remove Receive Connector' -ExpectedGetResults $expectedGetResults

        # Try to remove the same receive connector again. This should not cause any errors.
        $testStartTime = [DateTime]::Now

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Attempt Removal of Already Removed Receive Connector' -ExpectedGetResults $expectedGetResults

        Context 'When Get-ReceiveConnector is called and the connector is absent' {
            It 'Should not cause an error to be logged in the event log' {
                Get-EventLog -LogName 'MSExchange Management' -After $testStartTime -ErrorAction SilentlyContinue | `
                    Where-Object -FilterScript {$_.Message -like '*Cmdlet failed. Cmdlet Get-ReceiveConnector, parameters -Identity*'} |`
                    Should -Be $null
            }
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
