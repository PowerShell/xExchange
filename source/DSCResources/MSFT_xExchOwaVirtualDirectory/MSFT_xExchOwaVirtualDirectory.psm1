function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Allow', 'ForceSave', 'Block')]
        [System.String]
        $ActionForUnknownFileAndMIMETypes,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None', 'Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPrivateComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPrivateComputersEnabled,

        [Parameter()]
        [ValidateSet('FullDomain', 'UserName', 'PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain,

        [Parameter()]
        [System.Boolean]
        $SetPhotoEnabled
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OwaVirtualDirectory' -Verbose:$VerbosePreference

    $OwaVdir = Get-OwaVirtualDirectoryInternal @PSBoundParameters

    if ($null -ne $OwaVdir)
    {
        $returnValue = @{
            Identity                               = [System.String] $Identity
            ActionForUnknownFileAndMIMETypes       = [System.String] $OwaVdir.ActionForUnknownFileAndMIMETypes
            AdfsAuthentication                     = [System.Boolean] $OwaVdir.AdfsAuthentication
            BasicAuthentication                    = [System.Boolean] $OwaVdir.BasicAuthentication
            ChangePasswordEnabled                  = [System.Boolean] $OwaVdir.ChangePasswordEnabled
            DefaultDomain                          = [System.String] $OwaVdir.DefaultDomain
            DigestAuthentication                   = [System.Boolean] $OwaVdir.DigestAuthentication
            ExternalAuthenticationMethods          = [System.String[]] $OwaVdir.ExternalAuthenticationMethods
            ExternalUrl                            = [System.String] $OwaVdir.ExternalUrl.AbsoluteUri
            FormsAuthentication                    = [System.Boolean] $OwaVdir.FormsAuthentication
            GzipLevel                              = [System.String] $OwaVdir.GzipLevel
            InstantMessagingCertificateThumbprint  = [System.String] $OwaVdir.InstantMessagingCertificateThumbprint
            InstantMessagingEnabled                = [System.Boolean] $OwaVdir.InstantMessagingEnabled
            InstantMessagingServerName             = [System.String] $OwaVdir.InstantMessagingServerName
            InstantMessagingType                   = [System.String] $OwaVdir.InstantMessagingType
            InternalUrl                            = [System.String] $OwaVdir.InternalUrl.AbsoluteUri
            LogonFormat                            = [System.String] $OwaVdir.LogonFormat
            LogonPageLightSelectionEnabled         = [System.Boolean] $OwaVdir.LogonPageLightSelectionEnabled
            LogonPagePublicPrivateSelectionEnabled = [System.Boolean] $OwaVdir.LogonPagePublicPrivateSelectionEnabled
            UNCAccessOnPublicComputersEnabled      = [System.Boolean] $OwaVdir.UNCAccessOnPublicComputersEnabled
            UNCAccessOnPrivateComputersEnabled     = [System.Boolean] $OwaVdir.UNCAccessOnPrivateComputersEnabled
            WindowsAuthentication                  = [System.Boolean] $OwaVdir.WindowsAuthentication
            WSSAccessOnPublicComputersEnabled      = [System.Boolean] $OwaVdir.WSSAccessOnPublicComputersEnabled
            WSSAccessOnPrivateComputersEnabled     = [System.Boolean] $OwaVdir.WSSAccessOnPrivateComputersEnabled
            SetPhotoEnabled                        = [System.Boolean] $OwaVdir.SetPhotoEnabled
        }
    }

    $returnValue
}
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Allow', 'ForceSave', 'Block')]
        [System.String]
        $ActionForUnknownFileAndMIMETypes,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None', 'Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPrivateComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPrivateComputersEnabled,

        [Parameter()]
        [ValidateSet('FullDomain', 'UserName', 'PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain,

        [Parameter()]
        [System.Boolean]
        $SetPhotoEnabled
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-OwaVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    # Remove Credential and AllowServiceRestart because those parameters do not exist on Set-OwaVirtualDirectory
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-OwaVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeOWAAppPool'
        Restart-ExistingAppPool -Name MSExchangeOWAAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeOWAAppPool is manually recycled.'
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Allow', 'ForceSave', 'Block')]
        [System.String]
        $ActionForUnknownFileAndMIMETypes,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None', 'Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPrivateComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPrivateComputersEnabled,

        [Parameter()]
        [ValidateSet('FullDomain', 'UserName', 'PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain,

        [Parameter()]
        [System.Boolean]
        $SetPhotoEnabled
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OwaVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $OwaVdir = Get-OwaVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $OwaVdir)
    {
        Write-Error -Message 'Unable to retrieve OWA Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $OwaVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $OwaVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'FormsAuthentication' -Type 'Boolean' -ExpectedValue $FormsAuthentication -ActualValue $OwaVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $OwaVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $OwaVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ChangePasswordEnabled' -Type 'Boolean' -ExpectedValue $ChangePasswordEnabled -ActualValue $OwaVdir.ChangePasswordEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $OwaVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AdfsAuthentication' -Type 'Boolean' -ExpectedValue $AdfsAuthentication -ActualValue $OwaVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InstantMessagingType' -Type 'String' -ExpectedValue $InstantMessagingType -ActualValue $OwaVdir.InstantMessagingType -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InstantMessagingEnabled' -Type 'Boolean' -ExpectedValue $InstantMessagingEnabled -ActualValue $OwaVdir.InstantMessagingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InstantMessagingCertificateThumbprint' -Type 'String' -ExpectedValue $InstantMessagingCertificateThumbprint -ActualValue $OwaVdir.InstantMessagingCertificateThumbprint -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InstantMessagingServerName' -Type 'String' -ExpectedValue $InstantMessagingServerName -ActualValue $OwaVdir.InstantMessagingServerName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogonPagePublicPrivateSelectionEnabled' -Type 'Boolean' -ExpectedValue $LogonPagePublicPrivateSelectionEnabled -ActualValue $OwaVdir.LogonPagePublicPrivateSelectionEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogonPageLightSelectionEnabled' -Type 'Boolean' -ExpectedValue $LogonPageLightSelectionEnabled -ActualValue $OwaVdir.LogonPageLightSelectionEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalAuthenticationMethods' -Type 'Array' -ExpectedValue $ExternalAuthenticationMethods -ActualValue $OwaVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogonFormat' -Type 'String' -ExpectedValue $LogonFormat -ActualValue $OwaVdir.LogonFormat -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DefaultDomain' -Type 'String' -ExpectedValue $DefaultDomain -ActualValue $OwaVdir.DefaultDomain -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ActionForUnknownFileAndMIMETypes' -Type 'String' -ExpectedValue $ActionForUnknownFileAndMIMETypes -ActualValue $OwaVdir.ActionForUnknownFileAndMIMETypes -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WSSAccessOnPublicComputersEnabled' -Type 'Boolean' -ExpectedValue $WSSAccessOnPublicComputersEnabled -ActualValue $OwaVdir.WSSAccessOnPublicComputersEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WSSAccessOnPrivateComputersEnabled' -Type 'Boolean' -ExpectedValue $WSSAccessOnPrivateComputersEnabled -ActualValue $OwaVdir.WSSAccessOnPrivateComputersEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'UNCAccessOnPublicComputersEnabled' -Type 'Boolean' -ExpectedValue $UNCAccessOnPublicComputersEnabled -ActualValue $OwaVdir.UNCAccessOnPublicComputersEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'UNCAccessOnPrivateComputersEnabled' -Type 'Boolean' -ExpectedValue $UNCAccessOnPrivateComputersEnabled -ActualValue $OwaVdir.UNCAccessOnPrivateComputersEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'GzipLevel' -Type 'String' -ExpectedValue $GzipLevel -ActualValue $OwaVdir.GzipLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SetPhotoEnabled' -Type 'Boolean' -ExpectedValue $SetPhotoEnabled -ActualValue $OwaVdir.SetPhotoEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function Get-OwaVirtualDirectoryInternal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Allow', 'ForceSave', 'Block')]
        [System.String]
        $ActionForUnknownFileAndMIMETypes,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None', 'Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $UNCAccessOnPrivateComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPublicComputersEnabled,

        [Parameter()]
        [System.Boolean]
        $WSSAccessOnPrivateComputersEnabled,

        [Parameter()]
        [ValidateSet('FullDomain', 'UserName', 'PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain,

        [Parameter()]
        [System.Boolean]
        $SetPhotoEnabled
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-OwaVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
