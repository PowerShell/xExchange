<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchExchangeServer DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
        This module has the following additional requirements:
            * Requires that the ActiveDirectory module is installed
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchExchangeServer'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

# Sets properties retrieved by Get-ExchangeServer back to their default values
function Clear-PropsForExchDscServer
{
    [CmdletBinding()]
    param()

    Import-Module -Name ActiveDirectory
    Clear-ExchDscServerADProperty -Property 'msExchProductID'
    Clear-ExchDscServerADProperty -Property 'msExchCustomerFeedbackEnabled'
    Clear-ExchDscServerADProperty -Property 'msExchInternetWebProxy'
}

# Used to null out the specified Active Directory property of an Exchange Server
function Clear-ExchDscServerADProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.string]
        $Property
    )

    Get-ADObject -SearchBase "$($exchangeServerDN)" -Filter { ObjectClass -eq 'msExchExchangeServer' } | Where-Object -FilterScript {
        $_.ObjectClass -eq 'msExchExchangeServer'
    } | Set-ADObject -Clear "$($Property)"
}

function Test-ExchDscServerPrepped
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $GetTargetResourceParamaters
    )

    Context 'Server has had relevant properties nulled out for xExchExchangeServer tests' {
        [System.Collections.Hashtable] $getResult = Get-TargetResource @GetTargetResourceParamaters -Verbose

        # It 'InternetWebProxy should be empty' {
        #     [System.String]::IsNullOrEmpty($getResult.InternetWebProxy) | Should Be $false
        # }

        It 'ProductKey should be empty' {
            [System.String]::IsNullOrEmpty($getResult.ProductKey) | Should Be $true
        }
    }
}

$adModule = Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue

if ($null -ne $adModule)
{
    if ($exchangeInstalled)
    {
        # Get required credentials to use for the test
        $shellCredentials = Get-TestCredential

        if ($null -eq $exchangeServerDN)
        {
            Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-ExchangeServer'
            $server = Get-ExchangeServer -Identity $env:COMPUTERNAME

            if ($null -ne $server)
            {
                $exchangeServerDN = $server.DistinguishedName
            }

            if ($null -eq $exchangeServerDN)
            {
                throw 'Failed to determine distinguishedName of Exchange Server object'
            }

            # Remove our remote Exchange session so as not to interfere with actual Integration testing
            Remove-RemoteExchangeModule
        }

        # Get the product key to use for testing
        if ($null -eq $productKey)
        {
            $productKey = Read-Host -Prompt 'Enter the product key to license Exchange with, or press ENTER to skip testing the licensing of the server.'
        }

        $testDC = [System.Net.Dns]::GetHostByName($env:LOGONSERVER.Replace('\\', '')).HostName

        $serverVersion = Get-ExchangeVersionYear

        Describe 'Test Setting Properties with xExchExchangeServer' {
            # Create our initial test params
            $testParams = @{
                Identity                        = $env:COMPUTERNAME
                Credential                      = $shellCredentials
                ErrorReportingEnabled           = $false
                MonitoringGroup                 = $null
                StaticConfigDomainController    = $null
                StaticDomainControllers         = $null
                StaticExcludedDomainControllers = $testDC
                StaticGlobalCatalogs            = $null
            }

            $expectedGetResults = @{
                Identity                        = $env:COMPUTERNAME
                ErrorReportingEnabled           = $false
                MonitoringGroup                 = ''
                ProductKey                      = ''
                StaticConfigDomainController    = ''
                StaticDomainControllers         = [System.String[]] @()
                StaticExcludedDomainControllers = [System.String[]] @($testDC)
                StaticGlobalCatalogs            = [System.String[]] @()
            }

            if ($serverVersion -in @('2016'))
            {
                $testParams.Add('InternetWebProxyBypassList', $null)
                $expectedGetResults.Add('InternetWebProxyBypassList', [System.String[]] @())
            }

            # First prepare the server for tests
            Clear-PropsForExchDscServer
            Test-ExchDscServerPrepped -GetTargetResourceParamaters $testParams

            # Now do tests
            Test-TargetResourceFunctionality -Params $testParams `
                -ContextLabel 'Standard xExchExchangeServer tests' `
                -ExpectedGetResults $expectedGetResults

            # Alter a number of parameters
            # $testParams.InternetWebProxy = $expectedGetResults.InternetWebProxy = 'http://someproxy.local/'
            $testParams.MonitoringGroup = $expectedGetResults.MonitoringGroup = 'TestMonitoringGroup'
            $testParams.StaticConfigDomainController = $expectedGetResults.StaticConfigDomainController = $testDC
            $testParams.StaticDomainControllers = $expectedGetResults.StaticDomainControllers = $testDC
            $testParams.StaticGlobalCatalogs = $expectedGetResults.StaticGlobalCatalogs = $testDC
            $testParams.StaticExcludedDomainControllers = $null
            $expectedGetResults.StaticExcludedDomainControllers = [System.String[]] @()

            # Add the ProductKey parameter if we have one to work with
            if (![System.String]::IsNullOrEmpty($productKey))
            {
                $testParams.Add('ProductKey', $productKey)
                $expectedGetResults.ProductKey = 'Licensed'
            }

            if ($serverVersion -in @('2016'))
            {
                $testParams.InternetWebProxyBypassList = 'contoso.com'
                $expectedGetResults.InternetWebProxyBypassList = @('contoso.com')
            }

            # Re-run tests
            Test-TargetResourceFunctionality -Params $testParams `
                -ContextLabel 'Altered xExchExchangeServer tests' `
                -ExpectedGetResults $expectedGetResults

            # Try licensing server with AllowServiceRestart set to True
            Clear-PropsForExchDscServer
            Test-ExchDscServerPrepped -GetTargetResourceParamaters $testParams

            $testParams.AllowServiceRestart = $true

            # Re-run tests
            Test-TargetResourceFunctionality -Params $testParams `
                -ContextLabel 'Service restart after licensing tests' `
                -ExpectedGetResults $expectedGetResults
        }
    }
    else
    {
        Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS'
}
