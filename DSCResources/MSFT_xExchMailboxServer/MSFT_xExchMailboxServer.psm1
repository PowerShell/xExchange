[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscTestsPresent", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscExamplesPresent", "")]
[CmdletBinding()]
param()

function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $WacDiscoveryEndpoint
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxServer" -VerbosePreference $VerbosePreference

    $server = GetMailboxServer @PSBoundParameters

    if ($null -ne $server)
    {
        $returnValue = @{
            Identity = $Identity
            DatabaseCopyActivationDisabledAndMoveNow = $server.DatabaseCopyActivationDisabledAndMoveNow
            DatabaseCopyAutoActivationPolicy = $server.DatabaseCopyAutoActivationPolicy
            MaximumActiveDatabases = $server.MaximumActiveDatabases
            MaximumPreferredActiveDatabases = $server.MaximumPreferredActiveDatabases
        }

        $serverVersion = GetExchangeVersion

        if ($serverVersion -eq "2016")
        {
            $returnValue.Add("WacDiscoveryEndpoint", $server.WacDiscoveryEndpoint)
        }
<<<<<<< HEAD
        elseif ($serverVersion -eq "2013")
        {
            $returnValue.Add("CalendarRepairWorkCycle", $server.CalendarRepairWorkCycle)
            $returnValue.Add("CalendarRepairWorkCycleCheckpoint", $server.CalendarRepairWorkCycleCheckpoint)
            $returnValue.Add("MailboxProcessorWorkCycle", $server.MailboxProcessorWorkCycle)
            $returnValue.Add("ManagedFolderAssistantSchedule", $server.ManagedFolderAssistantSchedule)
            $returnValue.Add("ManagedFolderWorkCycle", $server.ManagedFolderWorkCycle)
            $returnValue.Add("ManagedFolderWorkCycleCheckpoint", $server.ManagedFolderWorkCycleCheckpoint)
            $returnValue.Add("OABGeneratorWorkCycle", $server.OABGeneratorWorkCycle)
            $returnValue.Add("OABGeneratorWorkCycleCheckpoint", $server.OABGeneratorWorkCycleCheckpoint)
            $returnValue.Add("PublicFolderWorkCycle", $server.PublicFolderWorkCycle)
            $returnValue.Add("PublicFolderWorkCycleCheckpoint", $server.PublicFolderWorkCycleCheckpoint)
            $returnValue.Add("SharingPolicyWorkCycle", $server.SharingPolicyWorkCycle)
            $returnValue.Add("SharingPolicyWorkCycleCheckpoint", $server.SharingPolicyWorkCycleCheckpoint)
            $returnValue.Add("SharingSyncWorkCycle", $server.SharingSyncWorkCycle)
            $returnValue.Add("SharingSyncWorkCycleCheckpoint", $server.SharingSyncWorkCycleCheckpoint)
            $returnValue.Add("SiteMailboxWorkCycle", $server.SiteMailboxWorkCycle)
            $returnValue.Add("SiteMailboxWorkCycleCheckpoint", $server.SiteMailboxWorkCycleCheckpoint)
            $returnValue.Add("TopNWorkCycle", $server.TopNWorkCycle)
            $returnValue.Add("TopNWorkCycleCheckpoint", $server.TopNWorkCycleCheckpoint)
            $returnValue.Add("UMReportingWorkCycle", $server.UMReportingWorkCycle)
            $returnValue.Add("UMReportingWorkCycleCheckpoint", $server.UMReportingWorkCycleCheckpoint)
        }
        else
        {
          Write-Verbose -Message "Could not detect Exchange version"
        }
=======
>>>>>>> parent of 6866c82... Added missing parameters to xExchMailboxServer as of #159
    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $WacDiscoveryEndpoint
    )
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-MailboxServer" -VerbosePreference $VerbosePreference

    #Setup params for next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

    #Check for non-existent parameters in Exchange 2013
    RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "WacDiscoveryEndpoint" -ResourceName "xExchMailboxServer" -ParamExistsInVersion "2016"

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-MailboxServer @PSBoundParameters

}


function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $WacDiscoveryEndpoint
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxServer","Set-MailboxServer" -VerbosePreference $VerbosePreference

    #Check for non-existent parameters in Exchange 2013
    RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "WacDiscoveryEndpoint" -ResourceName "xExchMailboxServer" -ParamExistsInVersion "2016"

    $server = GetMailboxServer @PSBoundParameters

    if ($null -eq $server) #Couldn't find the server, which is bad
    {
        return $false
    }
    else #Validate server params
    {
        if (!(VerifySetting -Name "DatabaseCopyActivationDisabledAndMoveNow" -Type "Boolean" -ExpectedValue $DatabaseCopyActivationDisabledAndMoveNow -ActualValue $server.DatabaseCopyActivationDisabledAndMoveNow -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DatabaseCopyAutoActivationPolicy" -Type "String" -ExpectedValue $DatabaseCopyAutoActivationPolicy -ActualValue $server.DatabaseCopyAutoActivationPolicy -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaximumActiveDatabases" -Type "String" -ExpectedValue $MaximumActiveDatabases -ActualValue $server.MaximumActiveDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaximumPreferredActiveDatabases" -Type "String" -ExpectedValue $MaximumPreferredActiveDatabases -ActualValue $server.MaximumPreferredActiveDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WacDiscoveryEndpoint" -Type "String" -ExpectedValue $WacDiscoveryEndpoint -ActualValue $server.WacDiscoveryEndpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

#Runs Get-MailboxServer, only specifying Identity, and optionally DomainController
function GetMailboxServer
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $WacDiscoveryEndpoint
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxServer @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource

