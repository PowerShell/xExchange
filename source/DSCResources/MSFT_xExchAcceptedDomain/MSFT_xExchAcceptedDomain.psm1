<#
    .SYNOPSIS
        Get the current state of an accepted domain
    .PARAMETER DomainName
        The domain name of the accepted domain.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AddressBookEnabled
        The AddressBookEnabled parameter specifies whether to enable recipient filtering for this accepted domain.
    .PARAMETER DomainType
        The DomainType parameter specifies the type of accepted domain that you want to configure.
    .PARAMETER Default
        The MakeDefault parameter specifies whether the accepted domain is the default domain.
    .PARAMETER MatchSubDomains
        The MatchSubDomains parameter enables mail to be sent by and received from users on any subdomain of this accepted domain.
    .PARAMETER Name
        The Name parameter specifies a unique name for the accepted domain object.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    param (
        [Parameter(Mandatory = $true)]
        [String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Write-Verbose -Message 'Getting the Exchange Accepted Domains List'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-AcceptedDomain' -Verbose:$VerbosePreference

    $acceptedDomain = Get-AcceptedDomain -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.DomainName -eq $DomainName }

    $acceptedDomainProperties = @(
        'Name'
        'DomainName'
        'AddressBookEnabled'
        'DomainType'
        'Default'
        'MatchSubDomains'
    )

    if ($null -ne $acceptedDomain)
    {
        $returnValue = @{
            Ensure = 'Present'
        }

        foreach ($property in $acceptedDomain.PSObject.Properties.Name)
        {
            if ([String] $acceptedDomain.$property -and $acceptedDomainProperties -contains $property)
            {
                if ($property -eq 'Default')
                {
                    $returnValue['MakeDefault'] = $acceptedDomain.$property
                } else {
                    $returnValue[$property] = $acceptedDomain.$property
                }
            }
        }
    }
    else
    {
        $returnValue = @{
            Ensure = 'Absent'
        }
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Sets the state of an accepted domain.
    .PARAMETER DomainName
        The domain name of the accepted domain.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AddressBookEnabled
        The AddressBookEnabled parameter specifies whether to enable recipient filtering for this accepted domain.
    .PARAMETER DomainType
        The DomainType parameter specifies the type of accepted domain that you want to configure.
    .PARAMETER Default
        The MakeDefault parameter specifies whether the accepted domain is the default domain.
    .PARAMETER MatchSubDomains
        The MatchSubDomains parameter enables mail to be sent by and received from users on any subdomain of this accepted domain.
    .PARAMETER Name
        The Name parameter specifies a unique name for the accepted domain object.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [Boolean]
        $AddressBookEnabled = $true,

        [Parameter()]
        [ValidateSet('Authoritative', 'ExternalRelay', 'InternalRelay')]
        [String]
        $DomainType,

        [Parameter()]
        [Boolean]
        $MakeDefault = $false,

        [Parameter()]
        [Boolean]
        $MatchSubDomains = $false,

        [Parameter()]
        [String]
        $Name

    )

    Write-Verbose -Message 'Setting the Exchange accepted domain settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    $acceptedDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*-AcceptedDomain' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove Credential, Ensure

    if ($acceptedDomain['Ensure'] -eq 'Present')
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message ('Removing the accepted domain {0}' -f $acceptedDomain.Name)
            Remove-AcceptedDomain -Identity $acceptedDomain.Name -confirm:$false
        }
        else
        {
            Write-Verbose -Message ('Accepted domain {0} not compliant. Setting the desired attributes.' -f $acceptedDomain.Name)

            $PSBoundParameters['Identity'] = $acceptedDomain['Name']
            $PSBoundParameters.Remove('DomainName')

            Set-AcceptedDomain @PSBoundParameters -confirm:$false
        }
    }
    else
    {
        Write-Verbose -Message ('Accepted domain {0} does not exist. Creating it...' -f $acceptedDomain.Name)

        if ($null -eq $PSBoundParameters['Name'])
        {
            New-AcceptedDomain -DomainName $DomainName -Name $DomainName -confirm:$false
            $PSBoundParameters['Identity'] = $DomainName
        }
        else
        {
            New-AcceptedDomain -DomainName $DomainName -Name $Name -confirm:$false
            $PSBoundParameters['Identity'] = $Name
        }

        $PSBoundParameters.Remove('DomainName')
        Set-AcceptedDomain @PSBoundParameters -confirm:$false
    }
}

<#
    .SYNOPSIS
        Tests the state of an accepted domain.
    .PARAMETER DomainName
        The domain name of the accepted domain.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AddressBookEnabled
        The AddressBookEnabled parameter specifies whether to enable recipient filtering for this accepted domain.
    .PARAMETER DomainType
        The DomainType parameter specifies the type of accepted domain that you want to configure.
    .PARAMETER Default
        The MakeDefault parameter specifies whether the accepted domain is the default domain.
    .PARAMETER MatchSubDomains
        The MatchSubDomains parameter enables mail to be sent by and received from users on any subdomain of this accepted domain.
    .PARAMETER Name
        The Name parameter specifies a unique name for the accepted domain object.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [Boolean]
        $AddressBookEnabled = $true,

        [Parameter()]
        [ValidateSet('Authoritative', 'ExternalRelay', 'InternalRelay')]
        [String]
        $DomainType,

        [Parameter()]
        [Boolean]
        $MakeDefault = $false,

        [Parameter()]
        [Boolean]
        $MatchSubDomains = $false,

        [Parameter()]
        [String]
        $Name
    )

    Write-Verbose -Message 'Testing the Exchange accepted domain settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $targetResourceInCompliance = $true

    $acceptedDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Verbose'
    $DifferenceObjectHashTable = @{ } + $PSBoundParameters

    if ($null -eq $PSBoundParameters['Name'])
    {
        $DifferenceObjectHashTable['Name'] = $DomainName
    }

    if ($acceptedDomain['Ensure'] -eq 'Absent' -and $Ensure -ne 'Absent')
    {
        $targetResourceInCompliance = $false
    }
    elseif ($acceptedDomain['Ensure'] -eq 'Absent' -and $Ensure -eq 'Absent')
    {
        $targetResourceInCompliance = $true
    }
    elseif ($acceptedDomain['Ensure'] -eq 'Present' -and $Ensure -eq 'Absent')
    {
        $targetResourceInCompliance = $false
    }
    else
    {
        $acceptedDomain['MakeDefault'] = $acceptedDomain['Default']
        $acceptedDomain.Remove('Default')
        $referenceObject = [PSCustomObject] $acceptedDomain
        $differenceObject = [PSCustomObject] $DifferenceObjectHashTable

        foreach ($property in $DifferenceObjectHashTable.Keys)
        {
            if (Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -Property $property)
            {
                Write-Verbose -Message ("Invalid setting '{0}'. Expected value: {1}. Actual value: {2}" -f $property, $DifferenceObjectHashTable[$property], $acceptedDomain[$property])
                $targetResourceInCompliance = $false
                break;
            }
        }
    }

    return $targetResourceInCompliance
}
