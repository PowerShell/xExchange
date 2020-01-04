function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DAGName,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation
    )

    Write-FunctionEntry -Parameters @{
        'MailboxServer' = $MailboxServer
        'DAGName'       = $DAGName
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    # Setup params
    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
        'Identity' = $PSBoundParameters['DAGName']
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $dag = Get-DatabaseAvailabilityGroup @PSBoundParameters -Status -ErrorAction SilentlyContinue

    if ($null -ne $dag -and $null -ne $dag.Servers)
    {
        # See if this server is already in the DAG
        $server = $dag.Servers | Where-Object { $_.Name -eq "$($MailboxServer)" }

        if ($null -ne $server)
        {
            $returnValue = @{
                MailboxServer = [System.String] $MailboxServer
                DAGName       = [System.String] $dag.Name
            }
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DAGName,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation
    )

    Write-FunctionEntry -Parameters @{
        'MailboxServer' = $MailboxServer
        'DAGName' = $DAGName
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Add-DatabaseAvailabilityGroupServer' -Verbose:$VerbosePreference

    # Setup params
    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
        'Identity' = $PSBoundParameters['DAGName']
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DAGName', 'Credential'

    $failoverClusteringRole = Get-WindowsFeature -Name Failover-Clustering -ErrorAction SilentlyContinue

    # Force a reboot if the cluster is in an InstallPending state
    if ($failoverClusteringRole.InstallState -like 'InstallPending')
    {
        Write-Warning -Message 'A reboot is required to finish installing the Failover-Clustering role. This must occur before the server can be added to the DAG.'
        Set-DSCMachineStatus -NewDSCMachineStatus 1
        return
    }

    Add-DatabaseAvailabilityGroupServer @PSBoundParameters
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
        $MailboxServer,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DAGName,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation
    )

    Write-FunctionEntry -Parameters @{
        'MailboxServer' = $MailboxServer
        'DAGName' = $DAGName
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    # Setup params
    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
        'Identity' = $PSBoundParameters['DAGName']
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $dag = Get-DatabaseAvailabilityGroup @PSBoundParameters -Status -ErrorAction SilentlyContinue

    $testResults = $true

    if ($null -eq $dag -or $dag.Name -notlike "$($DAGName)")
    {
        Write-Error -Message 'Unable to retrieve Database Availability Group settings'

        $testResults = $false
    }
    else
    {
        if ($null -eq ($dag.Servers | Where-Object { $_.Name -eq "$($MailboxServer)" }))
        {
            Write-Verbose -Message 'Server is not a member of the Database Availability Group'

            $testResults = $false
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
