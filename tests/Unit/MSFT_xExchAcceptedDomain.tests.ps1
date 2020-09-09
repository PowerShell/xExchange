$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchAcceptedDomain'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

$script:testEnvironment = Invoke-TestSetup -DSCModuleName $script:dscModuleName -DSCResourceName $script:dscResourceName

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {

        function New-AcceptedDomain
        {
            param (
                $DomainName,
                $Name
            )
        }
        function Set-AcceptedDomain
        {
            param (
                $Identity
            )
        }
        function Get-AcceptedDomain
        {
        }
        function Remove-AcceptedDomain
        {
            param (
                $Identity
            )
        }

        Describe 'MSFT_xExchAcceptedDomain\Get-TargetResource' -Tag 'Get' {

            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $getTargetResourceParams = @{
                DomainName = 'fakedomain.com'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getAcceptedDomaindOutput = @{
                AddressBookEnabled = [System.Boolean] $true
                DomainName         = [System.String] 'fakedomain.com'
                DomainType         = [System.String] 'Authoritative'
                Default        = [System.Boolean] $false
                MatchSubDomains    = [System.Boolean] $false
                Name               = [System.String] 'fakedomain.com'
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-AcceptedDomain -Verifiable -MockWith { return [PSCustomObject] $getAcceptedDomaindOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When resource is absent' {
                It 'Should call all functions' {
                    Mock -CommandName Get-AcceptedDomain -Verifiable

                    $result = Get-TargetResource @getTargetResourceParams
                    $result.Ensure | Should -Be 'Absent'
                }
            }
        }

        Describe 'MSFT_xExchAcceptedDomain\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Write-FunctionEntry -Verifiable
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

            $setAcceptedDomaindInput = @{
                AddressBookEnabled = [System.Boolean] $true
                Ensure             = 'Present'
                DomainName         = [System.String] 'fakedomain.com'
                DomainType         = [System.String] 'Authoritative'
                MakeDefault        = [System.Boolean] $false
                MatchSubDomains    = [System.Boolean] $false
                Credential         = $credential
            }

            Context 'When domain does not exist' {
                Mock -CommandName Get-TargetResource -MockWith {
                    return @{
                        Ensure = 'Absent'
                    }
                } -Verifiable

                Context 'No Name was specified' {
                    It 'Should call all functions' {
                        Mock -CommandName New-AcceptedDomain -ParameterFilter { $DomainName -eq 'fakedomain.com' -and $Name -eq 'fakedomain.com' } -Verifiable
                        Mock -CommandName Set-AcceptedDomain -ParameterFilter { $Identity -eq 'fakedomain.com' } -Verifiable

                        Set-TargetResource @setAcceptedDomaindInput
                    }
                }

                Context 'Name was specified' {
                    It 'Should call all functions' {
                        $setAcceptedDomaindInputName = @{ } + $setAcceptedDomaindInput
                        $setAcceptedDomaindInputName['Name'] = 'MyfakeDomain'

                        Mock -CommandName New-AcceptedDomain -ParameterFilter { $DomainName -eq 'fakedomain.com' -and $Name -eq 'MyfakeDomain' } -Verifiable
                        Mock -CommandName Set-AcceptedDomain -ParameterFilter { $Identity -eq 'MyfakeDomain' } -Verifiable

                        Set-TargetResource @setAcceptedDomaindInputName
                    }
                }
            }

            Context 'When domain exists' {
                Mock -CommandName Get-TargetResource -MockWith {
                    return @{
                        AddressBookEnabled = [System.Boolean] $true
                        DomainName         = [System.String] 'fakedomain.com'
                        DomainType         = [System.String] 'Authoritative'
                        MakeDefault        = [System.Boolean] $false
                        MatchSubDomains    = [System.Boolean] $false
                        Name               = [System.String] 'MyfakeDomain'
                        Ensure             = 'Present'
                    }
                } -Verifiable

                Context 'Ensure is set to "Present"' {
                    It 'Should call all functions' {
                        Mock -CommandName Set-AcceptedDomain -ParameterFilter { $Identity -eq 'MyfakeDomain' } -Verifiable

                        Set-TargetResource @setAcceptedDomaindInput
                    }
                }

                Context 'Ensure is set to "Absent"' {

                    It 'Should call all functions' {
                        $setAcceptedDomaindInputEnsure = @{ } + $setAcceptedDomaindInput
                        $setAcceptedDomaindInputEnsure['Ensure'] = 'Absent'

                        Mock -CommandName Remove-AcceptedDomain -ParameterFilter { $Identity -eq 'MyfakeDomain' } -Verifiable

                        Set-TargetResource @setAcceptedDomaindInputEnsure
                    }
                }
            }
        }

        Describe 'MSFT_xExchAcceptedDomain\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                Mock -CommandName Write-FunctionEntry -Verifiable
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

            $testAcceptedDomaindInput = @{
                AddressBookEnabled = [System.Boolean] $true
                Ensure             = 'Present'
                DomainName         = [System.String] 'fakedomain.com'
                DomainType         = [System.String] 'Authoritative'
                MakeDefault        = [System.Boolean] $false
                MatchSubDomains    = [System.Boolean] $false
                Name               = [System.String] 'MyFakeDomain'
                Credential         = $credential
            }

            $stubAcceptedDomain = @{
                AddressBookEnabled = [System.Boolean] $true
                DomainName         = [System.String] 'fakedomain.com'
                DomainType         = [System.String] 'Authoritative'
                Default            = [System.Boolean] $false
                MatchSubDomains    = [System.Boolean] $false
                Name               = [System.String] 'MyWrongFakeDomain'
                Ensure             = 'Present'
            }

            Context 'When domain is not present' {
                Context 'Should return false, when Ensure is set to "Present"' {
                    It 'Should call all functions' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Ensure = 'Absent'
                            }
                        } -Verifiable

                        Test-TargetResource @testAcceptedDomaindInput | Should -Be $false
                    }
                }

                Context 'Should return true, when Ensure is set to "Absent"' {
                    It 'Should call all functions' {
                        Mock -CommandName Get-TargetResource -MockWith {
                            return @{
                                Ensure = 'Absent'
                            }
                        } -Verifiable

                        $testAcceptedDomaindInputEnsure = @{ } + $testAcceptedDomaindInput
                        $testAcceptedDomaindInputEnsure['Ensure'] = 'Absent'

                        Test-TargetResource @testAcceptedDomaindInputEnsure | Should -Be $true
                    }
                }
            }

            Context 'When domain is present' {
                Context 'When "Ensure" is set to Absent' {
                    It 'Should return false' {
                        Mock -CommandName Get-TargetResource -MockWith { return $stubAcceptedDomain } -Verifiable

                        $testAcceptedDomaindInputAbsent = @{ } + $testAcceptedDomaindInput
                        $testAcceptedDomaindInputAbsent['Ensure'] = 'Absent'

                        Test-TargetResource @testAcceptedDomaindInputAbsent | Should -Be $false
                    }
                }

                Context 'Should return true when compliant and Name was not specified' {
                    It 'Should call all functions' {
                        $returnAcceptedDomain = @{ } + $stubAcceptedDomain
                        $returnAcceptedDomain['Name'] = 'fakedomain.com'

                        $testAcceptedDomaindInputNoName = @{ } + $testAcceptedDomaindInput
                        $testAcceptedDomaindInputNoName.Remove('Name')

                        Mock -CommandName Get-TargetResource -MockWith { return $returnAcceptedDomain } -Verifiable

                        Test-TargetResource @testAcceptedDomaindInputNoName | Should -Be $true
                    }
                }

                Context 'When compliant' {
                    It 'Should return true' {
                        $returnAcceptedDomain = @{ } + $stubAcceptedDomain
                        $returnAcceptedDomain['Name'] = 'MyFakeDomain'

                        Mock -CommandName Get-TargetResource -MockWith { return $returnAcceptedDomain } -Verifiable

                        Test-TargetResource @testAcceptedDomaindInput | Should -Be $true
                    }
                }

                Context 'When not compliant' {
                    It 'Should return false' {
                        Mock -CommandName Get-TargetResource -MockWith { return $stubAcceptedDomain } -Verifiable

                        Test-TargetResource @testAcceptedDomaindInput | Should -Be $false
                    }
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
