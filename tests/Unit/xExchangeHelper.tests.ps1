[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

#region HEADER
$script:projectPath = "$PSScriptRoot\..\.." | Convert-Path
$script:projectName = (Get-ChildItem -Path "$script:projectPath\*\*.psd1" | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            {
                Test-ModuleManifest -Path $_.FullName -ErrorAction Stop
            }
            catch
            {
                $false
            })
    }).BaseName

$script:parentModule = Get-Module -Name $script:projectName -ListAvailable | Select-Object -First 1
$script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'
Remove-Module -Name $script:parentModule -Force -ErrorAction 'SilentlyContinue'

$script:subModuleName = (Split-Path -Path $PSCommandPath -Leaf) -replace '\.Tests.ps1'
$script:subModuleFile = Join-Path -Path $script:subModulesFolder -ChildPath "$($script:subModuleName)"

Import-Module $script:subModuleFile -Force -ErrorAction Stop
Import-Module -Name (Join-Path -Path $script:projectPath -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force
#endregion HEADER
# Begin Testing
try
{
    InModuleScope $script:subModuleName {
        # Get a unique Guid that doesn't resolve to a local path
        # Use System.Guid, as New-Guid isn't available in PS4 and below
        do
        {
            $guid1 = [System.Guid]::NewGuid().ToString()
        } while (Test-Path -Path $guid1)

        # Get a unique Guid that doesn't resolve to a local path
        do
        {
            $guid2 = [System.Guid]::NewGuid().ToString()
        } while ((Test-Path -Path $guid2) -or $guid1 -like $guid2)

        Describe 'xExchangeHelper\Get-ExchangeInstallStatus' -Tag 'Helper' {
            # Used for calls to Get-InstallStatus
            $getInstallStatusParams = @{
                Path      = 'C:\Exchange\setup.exe'
                Arguments = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
            }

            AfterEach {
                Assert-MockCalled -CommandName Test-ShouldInstallUMLanguagePack -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ExchangeSetupRunning -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ExchangeSetupComplete -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ExchangePresent -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ShouldUpgradeExchange -Exactly -Times 1 -Scope It
            }

            Context 'When Exchange is not present on the system' {
                It 'Should only recommend starting the install' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $false }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $false }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $false
                    $installStatus.ShouldUpgrade | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange Setup has fully completed' {
                It 'Should indicate setup is complete and Exchange is present' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $true }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $false }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $true
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldUpgrade | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $false
                }
            }

            Context 'When Exchange Setup has partially completed' {
                It 'Should indicate that Exchange is present, but setup is not complete, and recommend starting an install' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $false }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldUpgrade | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange Setup is currently running' {
                It 'Should indicate that Exchange is present and that setup is running' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $true }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $false }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $true
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldUpgrade | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $false
                }
            }

            Context 'When a Language Pack install is requested, and the Language Pack has not been installed' {
                It 'Should indicate that setup has completed and a language pack Should -Be installed' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $true }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $true }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $false }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $true
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $true
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldUpgrade | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange upgrade is requested' {
                It 'Should recommend starting the install' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $true }

                    $getInstallStatusParams = @{
                        Path      = 'C:\Exchange\setup.exe'
                        Arguments = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'
                    }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldUpgrade | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Get-PreviousError' -Tag 'Helper' {
            Context 'After an error occurs' {
                It 'Should retrieve the most recent error' {
                    # First get whatever error is currently on top of the stack
                    $initialError = Get-PreviousError

                    # Cause an error by trying to get a non-existent item
                    Get-ChildItem -Path $guid1 -ErrorAction SilentlyContinue

                    $firstError = Get-PreviousError

                    # Cause another error by trying to get a non-existent item
                    Get-ChildItem -Path $guid2 -ErrorAction SilentlyContinue

                    $secondError = Get-PreviousError

                    $initialError -ne $firstError | Should -Be $true
                    $secondError -ne $firstError | Should -Be $true
                    $firstError -eq $null | Should -Be $false
                    $secondError -eq $null | Should -Be $false
                }
            }

            Context 'When an error has not occurred' {
                It 'Should return the same previous error with each call' {
                    # Run Get-PreviousError twice in a row so we can later ensure results are the same
                    $error1 = Get-PreviousError
                    $error2 = Get-PreviousError

                    # Run a command that should always succeed
                    Get-ChildItem | Out-Null

                    # Get the previous error one more time
                    $error3 = Get-PreviousError

                    $error1 -eq $error2 | Should -Be $true
                    $error1 -eq $error3 | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Assert-NoNewError' -Tag 'Helper' {
            Context 'After a new, unique error occurs' {
                It 'Should throw an exception' {
                    # First get whatever error is currently on top of the stack
                    $initialError = Get-PreviousError

                    # Cause an error by trying to get a non-existent item
                    Get-ChildItem $guid1 -ErrorAction SilentlyContinue

                    { Assert-NoNewError -CmdletBeingRun "Get-ChildItem" -PreviousError $initialError } | Should -Throw
                }
            }

            Context 'When an error has not occurred' {
                It 'Should not throw an exception' {
                    # First get whatever error is currently on top of the stack
                    $initialError = Get-PreviousError

                    # Run a command that should always succeed
                    Get-ChildItem | Out-Null

                    { Assert-NoNewError -CmdletBeingRun "Get-ChildItem" -PreviousError $initialError } | Should -Not -Throw
                }
            }
        }

        Describe 'xExchangeHelper\Assert-IsSupportedWithExchangeVersion' -Tag 'Helper' {
            $supportedVersionTestCases = @(
                @{Name = '2013 Operation Supported on 2013'; ExchangeVersion = '2013'; SupportedVersions = '2013' }
                @{Name = '2013 Operation Supported on 2013,2019'; ExchangeVersion = '2013'; SupportedVersions = '2013', '2019' }
            )

            $notSupportedVersionTestCases = @(
                @{Name = '2013 Operation Not Supported on 2016'; ExchangeVersion = '2013'; SupportedVersions = '2016' }
                @{Name = '2013 Operation Not Supported on 2016,2019'; ExchangeVersion = '2013'; SupportedVersions = '2016', '2019' }
            )

            Context 'When a supported version is passed' {
                It 'Should not throw an exception' -TestCases $supportedVersionTestCases {
                    param($Name, $ExchangeVersion, $SupportedVersions)

                    Mock -CommandName Get-ExchangeVersionYear -MockWith { return $ExchangeVersion }

                    { Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName $Name -SupportedVersions $SupportedVersions } | Should -Not -Throw
                }
            }

            Context 'When an unsupported version is passed' {
                It 'Should throw an exception' -TestCases $notSupportedVersionTestCases {
                    param($Name, $ExchangeVersion, $SupportedVersions)

                    Mock -CommandName Get-ExchangeVersionYear -MockWith { return $ExchangeVersion }

                    { Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName $Name -SupportedVersions $SupportedVersions } | Should -Throw
                }
            }
        }

        Describe 'xExchangeHelper\Compare-ADObjectIdToSmtpAddressString' -Tag 'Helper' {
            <#
                Define an empty function for Get-Recipient, so Pester has something to Mock.
                This cmdlet is normally loaded as part of GetRemoteExchangeSession.
            #>
            function Get-Recipient
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            # Setup test objects for calls to Compare-ADObjectIdToSmtpAddressString
            $testADObjectID = New-Object -TypeName PSObject -Property @{DistinguishedName = 'CN=TestUser,DC=contoso,DC=local' }
            $testAddress = 'testuser@contoso.local'
            $testBadAddress = 'baduser@contoso.local'

            $testRecipient = New-Object -TypeName PSObject -Property @{
                EmailAddresses = New-Object -TypeName PSObject -Property @{
                    AddressString = $testAddress
                }
            }

            Context 'When comparing an ADObjectID to a corresponding SMTP address' {
                It 'Should return $true' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }
                    Mock -CommandName Get-Recipient -Verifiable -MockWith { return $testRecipient }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testAddress

                    $compareResults | Should -Be $true
                }
            }

            Context 'When comparing an ADObjectID to a non-corresponding SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }
                    Mock -CommandName Get-Recipient -Verifiable -MockWith { return $testRecipient }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testBadAddress

                    $compareResults | Should -Be $false
                }
            }

            Context 'When comparing an ADObjectID to an empty SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString ''

                    $compareResults | Should -Be $false
                }
            }

            Context 'When comparing an ADObjectID to a null SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $null

                    $compareResults | Should -Be $false
                }
            }

            Context 'When comparing a null ADObjectID to an empty SMTP address' {
                It 'Should return $true' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString ''

                    $compareResults | Should -Be $true
                }
            }

            Context 'When comparing a null ADObjectID to a null SMTP address' {
                It 'Should return $true' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString $null

                    $compareResults | Should -Be $true
                }
            }

            Context 'When comparing a null ADObjectID to any SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString $testAddress

                    $compareResults | Should -Be $false
                }
            }

            Context 'When Get-Recipient returns $null' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }
                    Mock -CommandName Get-Recipient -Verifiable -MockWith { return $null }

                    { Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testBadAddress | Out-Null } | Should -Throw
                }
            }

            Context 'When Get-Command returns $null' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return $null }

                    { Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testBadAddress | Out-Null } | Should -Throw
                }
            }
        }

        Describe 'xExchangeHelper\Invoke-DotSourcedScript' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Invoke-DotSourcedScript is called with no parameters' {
                It 'Should execute fine' {
                    $processes = Invoke-DotSourcedScript -ScriptPath 'Get-Process'

                    $processes.Count | Should -BeGreaterThan 0
                }
            }

            Context 'When Invoke-DotSourcedScript is called with parameters' {
                It 'Should execute fine' {
                    $testProcess = 'svchost'
                    $scriptParams = @{
                        Name = $testProcess
                    }

                    $processes = Invoke-DotSourcedScript -ScriptPath 'Get-Process' -ScriptParams $scriptParams

                    ($processes | Where-Object -FilterScript { $_.ProcessName -like $testProcess }).Count | Should -BeGreaterThan 0
                }
            }

            Context 'When Invoke-DotSourcedScript is called with SnapinsToRemove' {
                It 'Should call Remove-HelperSnapin' {
                    Mock -CommandName Remove-HelperSnapin -Verifiable

                    Invoke-DotSourcedScript -ScriptPath 'Get-Process' -SnapinsToRemove 'SomeSnapin' | Out-Null
                }
            }

            Context 'When Invoke-DotSourcedScript is called and CommandsToExecuteInScope is passed' {
                It 'Should execute the commands and return values from those commands' {
                    $commandToExecuteAfterDotSourcing = @('Get-Process')
                    $commandParamsToExecuteAfterDotSourcing = @{
                        'Get-Process' = @{
                            Name = 'svchost'
                        }
                    }

                    $returnValues = Invoke-DotSourcedScript -ScriptPath 'Start-Sleep' -ScriptParams @{Seconds = 0 } -CommandsToExecuteInScope $commandToExecuteAfterDotSourcing -ParamsForCommandsToExecuteInScope $commandParamsToExecuteAfterDotSourcing

                    $returnValues.Count -gt 0 -and $returnValues.ContainsKey('Get-Process') -and $null -ne $returnValues['Get-Process'] | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Remove-HelperSnapin' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Remove-HelperSnapin is called and a snapin is loaded' {
                It 'Should remove the snapin' {
                    Mock -CommandName Get-PSSnapin -Verifiable -MockWith { return $true }
                    Mock -CommandName Remove-PSSnapin -Verifiable

                    Remove-HelperSnapin -SnapinsToRemove 'FakeSnapin'
                }
            }

            Context 'When Remove-HelperSnapin is called and a snapin is not loaded' {
                It 'Should execute without attempting to remove a snapin' {
                    Mock -CommandName Get-PSSnapin -Verifiable
                    Mock -CommandName Remove-PSSnapin

                    Remove-HelperSnapin -SnapinsToRemove 'FakeSnapin'

                    Assert-MockCalled -CommandName Remove-PSSnapin -Times 0
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangePresent' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $validExchangeYears = @(
                @{Year = '2013' }
                @{Year = '2016' }
                @{Year = '2019' }
            )

            Context 'When Test-ExchangePresent is called with a valid Exchange Version' {
                It 'Should return True' -TestCases $validExchangeYears {
                    param
                    (
                        [System.Object]
                        $Year
                    )

                    Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return $Year }

                    Test-ExchangePresent | Should -Be $true
                }
            }

            $inValidExchangeYears = @(
                @{Year = '2012' }
                @{Year = '' }
                @{Year = 'N/A' }
                @{Year = $null }
            )

            Context 'When Test-ExchangePresent is called with an invalid Exchange Version' {
                It 'Should return False' -TestCases $inValidExchangeYears {
                    param
                    (
                        [System.Object]
                        $Year
                    )

                    Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return $Year }

                    Test-ExchangePresent | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetupComplete' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $setupCompleteCases = @(
                @{
                    ExchangePresent   = $true
                    PartiallyComplete = $false
                }
            )

            Context 'When Test-ExchangeSetupComplete is called and setup is fully complete' {
                It 'Should return true' -TestCases $setupCompleteCases {
                    param
                    (
                        [System.Boolean]
                        $ExchangePresent,

                        [System.Boolean]
                        $PartiallyComplete
                    )

                    Mock -CommandName Test-ExchangePresent -Verifiable -MockWith { return $ExchangePresent }
                    Mock -CommandName Test-ExchangeSetupPartiallyCompleted -Verifiable -MockWith { return $PartiallyComplete }

                    Test-ExchangeSetupComplete | Should -Be $true
                }
            }

            $setupIncompleteCases = @(
                @{
                    ExchangePresent   = $false
                    PartiallyComplete = $false
                }
                @{
                    ExchangePresent   = $true
                    PartiallyComplete = $true
                }
                @{ # This last one shouldn't be possible, but let's test for it anyways
                    ExchangePresent   = $false
                    PartiallyComplete = $true
                }
            )

            Context 'When Test-ExchangeSetupComplete is called and setup is not fully complete' {
                It 'Should return false' -TestCases $setupIncompleteCases {
                    param
                    (
                        [System.Boolean]
                        $ExchangePresent,

                        [System.Boolean]
                        $PartiallyComplete
                    )

                    Mock -CommandName Test-ExchangePresent -Verifiable -MockWith { return $ExchangePresent }
                    Mock -CommandName Test-ExchangeSetupPartiallyCompleted -Verifiable -MockWith { return $PartiallyComplete }

                    Test-ExchangeSetupComplete | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetupPartiallyCompleted' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ExchangeSetupPartiallyCompleted is called and no setup progress related registry keys remain' {
                It 'Should return false' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith {
                        return @{
                            UnpackedVersion   = 1
                            ConfiguredVersion = 1
                        }
                    }

                    Test-ExchangeSetupPartiallyCompleted | Should -Be $false
                }
            }

            $partiallyCompletedTestCases = @(
                @{
                    UnpackedVersion   = 1
                    ConfiguredVersion = 1
                    Action            = 1
                }
                @{
                    UnpackedVersion   = 1
                    ConfiguredVersion = 1
                    Watermark         = 1
                }
                @{
                    UnpackedVersion   = 1
                    ConfiguredVersion = 1
                    Action            = 1
                    Watermark         = 1
                }
                @{
                    UnpackedVersion = 1
                    Action          = 1
                    Watermark       = 1
                }
            )

            Context 'When Test-ExchangeSetupPartiallyCompleted is called and setup progress related registry keys remain' {
                It 'Should return true' -TestCases $partiallyCompletedTestCases {
                    param
                    (
                        [Nullable[System.Int32]]
                        $UnpackedVersion,

                        [Nullable[System.Int32]]
                        $ConfiguredVersion,

                        [Nullable[System.Int32]]
                        $Action,

                        [Nullable[System.Int32]]
                        $Watermark
                    )

                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith {
                        return @{
                            UnpackedVersion   = $UnpackedVersion
                            ConfiguredVersion = $ConfiguredVersion
                            Action            = $Action
                            Watermark         = $Watermark
                        }
                    }
                    Mock -CommandName Write-Warning -Verifiable

                    Test-ExchangeSetupPartiallyCompleted | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Set-WSManConfigStatus' -Tag 'Helper' {
            # Define an empty winrm function so we can Mock calls to the winrm executable
            function winrm
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-WSManConfigStatus is called and the UpdatedConfig key does not exist' {
                It 'Should attempt to configure WinRM' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{SomeOtherProp = 'SomeOtherValue' } }
                    Mock -CommandName Set-Location -Verifiable
                    Mock -CommandName winrm -Verifiable

                    Set-WSManConfigStatus
                }
            }

            Context 'When Set-WSManConfigStatus is called and the UpdatedConfig key exists' {
                It 'Should execute without attempting to configure WinRM' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{UpdatedConfig = 'SomeValue' } }
                    Mock -CommandName winrm

                    Set-WSManConfigStatus

                    Assert-MockCalled -CommandName winrm -Times 0
                }
            }

            Context 'When Set-WSManConfigStatus is called and the WSMan key does not exist' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return $null }

                    { Set-WSManConfigStatus } | Should -Throw -ExpectedMessage 'Unable to find registry key: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN'
                }
            }
        }

        Describe 'xExchangeHelper\Test-UMLanguagePackInstalled' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $testCultureName = 'TestCulture'

            Context 'When Test-UMLanguagePackInstalled is called and the specified Culture key exists' {
                It 'Should return true' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{TestCulture = $testCultureName } }

                    Test-UMLanguagePackInstalled -Culture $testCultureName | Should -Be $true
                }
            }

            Context 'When Test-UMLanguagePackInstalled is called and the specified Culture key does not exist' {
                It 'Should return false' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{SomeOtherCulture = 'SomeOtherCulture' } }

                    Test-UMLanguagePackInstalled -Culture $testCultureName | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ShouldInstallUMLanguagePack' -Tag 'Helper' {
            $noLanguagePackArgs = '/IAcceptExchangeServerLicenseTerms /mode:Install /r:MB'
            $singleLanguagePackArgs = '/AddUmLanguagePack:ja-JP /s:d:\Exchange\UMLanguagePacks /IAcceptExchangeServerLicenseTerms'
            $multiLanguagePackArgs = '/AddUmLanguagePack:es-MX,de-DE /s:d:\Exchange\UMLanguagePacks /IAcceptExchangeServerLicenseTerms'

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ShouldInstallUMLanguagePack is called and AddUMLanguagePack is not specified' {
                It 'Should return false' {
                    Test-ShouldInstallUMLanguagePack -Arguments $noLanguagePackArgs | Should -Be $false
                }
            }

            Context 'When Test-ShouldInstallUMLanguagePack is called with AddUMLanguagePack, a language is specified, and the language pack is not installed' {
                It 'Should return true' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $false }

                    Test-ShouldInstallUMLanguagePack -Arguments $singleLanguagePackArgs | Should -Be $true
                }

                It 'Should return true' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $false }

                    Test-ShouldInstallUMLanguagePack -Arguments $multiLanguagePackArgs | Should -Be $true
                }
            }

            Context 'When Test-ShouldInstallUMLanguagePack is called with AddUMLanguagePack, a language is specified, and the language pack is installed' {
                It 'Should return false' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $true }

                    Test-ShouldInstallUMLanguagePack -Arguments $singleLanguagePackArgs | Should -Be $false
                }

                It 'Should return false' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $true }

                    Test-ShouldInstallUMLanguagePack -Arguments $multiLanguagePackArgs | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetupRunning' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ExchangeSetupRunning is called and the setup process is running' {
                It 'Should return true' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return 'SomeProcess' }

                    Test-ExchangeSetupRunning | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetupRunning is called and the setup process is not running' {
                It 'Should return false' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return $null }

                    Test-ExchangeSetupRunning | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Wait-ForProcessStart' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Wait-ForProcessStart is called and the given process is detected' {
                It 'Should return true' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return 'SomeProcess' }

                    Wait-ForProcessStart -ProcessName 'SomeProcess' | Should -Be $true
                }
            }

            Context 'When Wait-ForProcessStart is called and the given process is not detected' {
                It 'Should return false' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return $null }

                    Wait-ForProcessStart -ProcessName 'SomeProcess' -SecondsPerSleep 0 -MaxSleepCycles 1 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Wait-ForProcessStop' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Wait-ForProcessStop is called and the given process stops' {
                It 'Should return true' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return $null }

                    Wait-ForProcessStop -ProcessName 'SomeProcess' | Should -Be $true
                }
            }

            Context 'When Wait-ForProcessStop is called and the given process does not stop' {
                It 'Should return false' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return 'SomeProcess' }

                    Wait-ForProcessStop -ProcessName 'SomeProcess' -SecondsPerSleep 0 -MaxSleepCycles 1 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Assert-ExchangeSetupArgumentsComplete' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Assert-ExchangeSetupArgumentsComplete is called and setup is complete' {
                It 'Should execute without throwing an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            SetupComplete = $true
                        }
                    }

                    { Assert-ExchangeSetupArgumentsComplete -Path 'c:\Exchange\setup.exe' -Arguments 'SetupArgs' } | Should -Not -Throw
                }
            }

            Context 'When Assert-ExchangeSetupArgumentsComplete is called and setup is not complete' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            SetupComplete = $false
                        }
                    }

                    { Assert-ExchangeSetupArgumentsComplete -Path 'c:\Exchange\setup.exe' -Arguments 'SetupArgs' } | Should -Throw -ExpectedMessage 'Exchange setup did not complete successfully. See "<system drive>\ExchangeSetupLogs\ExchangeSetup.log" for details.'
                }
            }

            Context 'When Assert-ExchangeSetupArgumentsComplete is called with wrong file path' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith {
                        return $false
                    }

                    { Assert-ExchangeSetupArgumentsComplete -Path 'c:\Exchange\setup.exe' -Arguments 'SetupArgs' } | Should -Throw -ExpectedMessage "Path to Exchange setup 'c:\Exchange\setup.exe' does not exists."
                }
            }
        }

        Describe 'xExchangeHelper\Get-ExchangeVersionYear' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $validProductVersions = @(
                @{
                    VersionMajor = 15
                    VersionMinor = 0
                    Year         = '2013'
                }
                @{
                    VersionMajor = 15
                    VersionMinor = 1
                    Year         = '2016'
                }
                @{
                    VersionMajor = 15
                    VersionMinor = 2
                    Year         = '2019'
                }
            )

            $invalidProductVersions = @(
                @{
                    VersionMajor = 15
                    VersionMinor = 7
                    Year         = $null
                }
                @{
                    VersionMajor = 14
                    VersionMinor = 0
                    Year         = $null
                }
            )

            Context 'When Get-ExchangeVersionYear is called and finds a valid VersionMajor and VersionMinor' {
                It 'Should return the correct Exchange year' -TestCases $validProductVersions {
                    param
                    (
                        [System.Int32]
                        $VersionMajor,

                        [System.Int32]
                        $VersionMinor,

                        [System.String]
                        $Year
                    )

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return @{
                            VersionMajor = $VersionMajor
                            VersionMinor = $VersionMinor
                        }
                    }

                    Get-ExchangeVersionYear | Should -Be $Year
                }
            }

            Context 'When Get-ExchangeVersionYear is called and finds an invalid VersionMajor or VersionMinor without ThrowIfUnknownVersion' {
                It 'Should return <Year>' -TestCases $invalidProductVersions {
                    param
                    (
                        [System.Int32]
                        $VersionMajor,

                        [System.Int32]
                        $VersionMinor,

                        [System.String]
                        $Year
                    )

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return @{
                            VersionMajor = $VersionMajor
                            VersionMinor = $VersionMinor
                        }
                    }

                    Get-ExchangeVersionYear | Should -Be $null
                }
            }

            Context 'When Get-ExchangeVersionYear is called and finds an invalid VersionMajor or VersionMinor and ThrowIfUnknownVersion is specified' {
                It 'Should throw an exception' -TestCases $invalidProductVersions {
                    param
                    (
                        [System.Int32]
                        $VersionMajor,

                        [System.Int32]
                        $VersionMinor,

                        [System.String]
                        $Year
                    )

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return @{
                            VersionMajor = $VersionMajor
                            VersionMinor = $VersionMinor
                        }
                    }

                    { Get-ExchangeVersionYear -ThrowIfUnknownVersion $true } | Should -Throw -ExpectedMessage 'Failed to discover a known Exchange Version'
                }
            }
        }

        Describe 'xExchangeHelper\Get-ExchangeUninstallKey' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-ExchangeUninstallKey is called and Exchange 2016 or 2019 is installed' {
                It 'Should return the 2016/2019 uninstall key' {
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter { $Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}' } -MockWith { return $true }

                    Get-ExchangeUninstallKey | Should -Be -Not $Null
                }
            }

            Context 'When Get-ExchangeUninstallKey is called and Exchange 2013 is installed' {
                It 'Should return the 2016/2019 uninstall key' {
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter { $Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}' } -MockWith { return $null }
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter { $Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4934D1EA-BE46-48B1-8847-F1AF20E892C1}' } -MockWith { return $true }

                    Get-ExchangeUninstallKey | Should -Be -Not $Null
                }
            }

            Context 'When Get-ExchangeUninstallKey is called and no Exchange is installed' {
                It 'Should return NULL' {
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter { $Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}' } -MockWith { return $null }
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter { $Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4934D1EA-BE46-48B1-8847-F1AF20E892C1}' } -MockWith { return $null }

                    Get-ExchangeUninstallKey | Should -Be $Null
                }
            }
        }

        Describe 'xExchangeHelper\Get-DetailedInstalledVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When DetailedInstalledVersion is called and a valid key is returned by Get-ExchangeUninstallKey' {
                It 'Should return custom object with VersionMajor and VersionMinor properties' {
                    Mock -CommandName Get-ExchangeUninstallKey -Verifiable -MockWith { return @{Name = 'SomeKeyName' } }
                    Mock -CommandName Get-ItemProperty -Verifiable -ParameterFilter { $Name -eq 'DisplayVersion' } -MockWith {
                        return [PSCustomObject] @{DisplayVersion = '15.1.1531.13' } }
                    Mock -CommandName Get-ItemProperty -Verifiable -ParameterFilter { $Name -eq 'VersionMajor' } -MockWith {
                        return [PSCustomObject] @{VersionMajor = 15 } }
                    Mock -CommandName Get-ItemProperty -Verifiable -ParameterFilter { $Name -eq 'VersionMinor' } -MockWith {
                        return [PSCustomObject] @{ VersionMinor = 1 }
                    }

                    $installedVersionDetails = Get-DetailedInstalledVersion

                    $installedVersionDetails.VersionMajor | Should -Be 15
                    $installedVersionDetails.VersionMinor | Should -Be 1
                    $installedVersionDetails.VersionBuild | Should -Be 1531
                    $installedVersionDetails.DisplayVersion | Should -Be '15.1.1531.13'
                }
            }

            Context 'When DetailedInstalledVersion is called and no valid key is returned by Get-ExchangeUninstallKey' {
                It 'Should return NULL' {
                    Mock -CommandName Get-ExchangeUninstallKey -Verifiable -MockWith { return $null }

                    Get-DetailedInstalledVersion | Should -Be $null
                }
            }
        }

        Describe 'Test-ShouldUpgradeExchange' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $cases = @(
                @{
                    Case                 = 'Setup.exe is newer. Commandline Argment is /mode:Upgrade'
                    SetupVersionMajor    = 15
                    SetupVersionMinor    = 1
                    SetupVersionBuild    = 2000
                    ExchangeVersionMajor = 15
                    ExchangeVersionMinor = 1
                    ExchangeVersionBuild = 1800
                    Result               = $true
                    Arguments            = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'
                }
                @{
                    Case                 = 'Setup.exe is newer. Commandline Argment is /m:Upgrade'
                    SetupVersionMajor    = 15
                    SetupVersionMinor    = 1
                    SetupVersionBuild    = 2000
                    ExchangeVersionMajor = 15
                    ExchangeVersionMinor = 1
                    ExchangeVersionBuild = 1800
                    Result               = $true
                    Arguments            = '/m:upgrade /Iacceptexchangeserverlicenseterms'
                }
                @{
                    Case                 = 'Setup.exe and installed Exchange version is the same.'
                    SetupVersionMajor    = 15
                    SetupVersionMinor    = 1
                    SetupVersionBuild    = 2000
                    ExchangeVersionMajor = 15
                    ExchangeVersionMinor = 1
                    ExchangeVersionBuild = 2000
                    Result               = $false
                    Arguments            = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'
                }
                @{
                    Case                 = 'Installed Exchange version is different than the setup.exe. e.g. 2013, 2016'
                    SetupVersionMajor    = 15
                    SetupVersionMinor    = 1
                    SetupVersionBuild    = 2000
                    ExchangeVersionMajor = 15
                    ExchangeVersionMinor = 0
                    ExchangeVersionBuild = 2000
                    Result               = $false
                    Arguments            = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'
                }
                @{
                    Case                 = 'Setup.exe version is different than the installed Exchange. e.g. 2013, 2016'
                    SetupVersionMajor    = 15
                    SetupVersionMinor    = 0
                    SetupVersionBuild    = 2000
                    ExchangeVersionMajor = 15
                    ExchangeVersionMinor = 1
                    ExchangeVersionBuild = 2000
                    Result               = $false
                    Arguments            = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'
                }
            )

            Context 'When Test-ShouldUpgradeExchange is called for different cases.' {
                It 'For case <Case> should return <Result>' -TestCases $cases {

                    Param(
                        [System.String]
                        $Case,

                        [System.Int32]
                        $SetupVersionMajor,

                        [System.Int32]
                        $SetupVersionMinor,

                        [System.Int32]
                        $SetupVersionBuild,

                        [System.Int32]
                        $ExchangeVersionMajor,

                        [System.Int32]
                        $ExchangeVersionMinor,

                        [System.Int32]
                        $ExchangeVersionBuild,

                        [System.Boolean]
                        $Result,

                        [System.String]
                        $Arguments
                    )

                    Mock -CommandName Get-SetupExeVersion -Verifiable -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = $SetupVersionMajor
                            VersionMinor = $SetupVersionMinor
                            VersionBuild = $SetupVersionBuild
                        }
                    }

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = $ExchangeVersionMajor
                            VersionMinor = $ExchangeVersionMinor
                            VersionBuild = $ExchangeVersionBuild
                        }
                    }

                    Test-ShouldUpgradeExchange -Path 'test' -Arguments $Arguments | Should -Be $Result
                }
            }

            Context 'When Get-SetupExeVersion returns null within Test-ShouldUpgradeExchange.' {
                It 'Should return $false' {
                    $Arguments = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'

                    Mock -CommandName Get-SetupExeVersion -Verifiable -MockWith {
                        return $null
                    }

                    Mock -CommandName Write-Error -Verifiable -MockWith { }

                    Test-ShouldUpgradeExchange -Path 'test' -Arguments $Arguments | Should -Be $false
                }
            }

            Context 'When Get-DetailedInstalledVersion returns null within Test-ShouldUpgradeExchange.' {
                It 'Should return with $false' {
                    $Arguments = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'

                    Mock -CommandName Write-Error -Verifiable -MockWith { }

                    Mock -CommandName Get-SetupExeVersion -Verifiable -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = 15
                            VersionMinor = 1
                            VersionBuild = 1234
                        }
                    }

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return $null
                    }

                    Test-ShouldUpgradeExchange -Path 'test' -Arguments $Arguments | Should -Be $false
                }
            }

            Context 'When Get-DetailedInstalledVersion and Get-SetupExeVersion return null within Test-ShouldUpgradeExchange.' {
                It 'Should return with $false' {
                    $Arguments = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'

                    Mock -CommandName Write-Error -Verifiable -MockWith { }

                    Mock -CommandName Get-SetupExeVersion -Verifiable -MockWith {
                        return $false
                    }

                    Test-ShouldUpgradeExchange -Path 'test' -Arguments $Arguments | Should -Be $false
                }
            }

            Context 'When calling Test-ShouldUpgradeExchange with commandline arguments, which belongs to a simple install not to an upgrade.' {
                It 'Should return with $false' {
                    $Arguments = '/mode:Install /role:Mailbox /IAcceptExchangeServerLicenseTerms'

                    Test-ShouldUpgradeExchange -Path 'test' -Arguments $Arguments | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Get-SetupExeVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-SetupExeVersion is called and the setup executable is found.' {
                It 'Should return the file version information.' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $true }
                    Mock -CommandName Get-ChildItem -Verifiable -MockWith {
                        @{
                            VersionInfo = @{
                                ProductMajorPart = 1
                                ProductMinorPart = 2
                                ProductBuildPart = 3
                            }
                        }
                    }

                    $version = Get-SetupExeVersion -Path 'SomePath'

                    $version.VersionMajor | Should -Be 1
                    $version.VersionMinor | Should -Be 2
                    $version.VersionBuild | Should -Be 3
                }
            }

            Context 'When Get-SetupExeVersion is called and the setup executable is not found' {
                It 'Should return NULL.' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $false }

                    Get-SetupExeVersion -Path 'SomePath' | Should -Be $null
                }
            }
        }

        Describe 'xExchangeHelper\Get-RemoteExchangeSession' -Tag 'Helper' {
            function Export-PSSession
            {

            }
            AfterEach {
                Assert-VerifiableMock
            }

            $script:DSCExchangeModuleName = 'DSCExchangeModule'
            $script:DSCExchangeModulePath = "$env:Temp\DSCExchangeModuleName"


            Context 'When Get-RemoteExchangeSession is called and Exchange setup is running' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-ExchangeSetupRunning -Verifiable -MockWith { return $true }

                    { Get-RemoteExchangeSession } | `
                            Should -Throw -ExpectedMessage 'Exchange Setup is currently running. Preventing creation of new Remote PowerShell session to Exchange.'
                }
            }

            Context 'When Get-RemoteExchangeSession is called, setup is not running, and no exported module exists' {
                It 'Should export the module' {
                    Mock -CommandName Test-ExchangeSetupRunning -Verifiable -MockWith { return $false }
                    Mock -CommandName Get-ExistingRemoteExchangeSession -Verifiable -MockWith {
                        return @{
                            State = 'Opened'
                        }
                    }
                    Mock -CommandName New-RemoteExchangeSession -Verifiable -MockWith {
                        return @{
                            State = 'Opened'
                        }
                    }
                    Mock -CommandName Export-PSSession
                    Mock -CommandName Import-Module

                    Get-RemoteExchangeSession

                    Assert-MockCalled -CommandName New-RemoteExchangeSession -Times 1
                    Assert-MockCalled -CommandName Export-PSSession -Times 1
                    Assert-MockCalled -CommandName Import-Module -Times 1
                }
            }

            Context 'When Get-RemoteExchangeSession is called, setup is not running, exported module exists and there is no existing session' {
                It 'Should create a session and import the module' {
                    Mock -CommandName Test-ExchangeSetupRunning -Verifiable -MockWith { return $false }
                    Mock -CommandName Get-ExistingRemoteExchangeSession -Verifiable -MockWith { return $null }
                    Mock -CommandName Test-Path -ParameterFilter { $Path -eq $script:DSCExchangeModulePath } -Verifiable -MockWith { $true }
                    Mock -CommandName New-RemoteExchangeSession -Verifiable -MockWith {
                        return @{
                            State = 'Opened'
                        }
                    }
                    Mock -CommandName Import-Module -Verifiable

                    Get-RemoteExchangeSession

                    Assert-MockCalled -CommandName New-RemoteExchangeSession -Times 1
                    Assert-MockCalled -CommandName Import-Module -Times 1
                }
            }

            Context 'When Get-RemoteExchangeSession is called, setup is not running, exported module exists and there is a existing session' {
                It 'Should only import the module' {
                    Mock -CommandName Test-ExchangeSetupRunning -Verifiable -MockWith { return $false }
                    Mock -CommandName Get-ExistingRemoteExchangeSession -Verifiable -MockWith {
                        return @{
                            State = 'Opened'
                        }
                    }
                    Mock -CommandName Test-Path -ParameterFilter { $Path -eq $DSCExchangeModulePath } -Verifiable -MockWith { $true }
                    Mock -CommandName Import-Module -Verifiable

                    Get-RemoteExchangeSession

                    Assert-MockCalled -CommandName Import-Module -Times 1
                }
            }
        }

        Describe 'xExchangeHelper\New-RemoteExchangeSession' -Tag 'Helper' {
            # Define empty function _NewExchangeRunspace so Mock can override it
            function _NewExchangeRunspace
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $script:DSCExchangeModuleName = 'DSCExchangeModule'
            $script:DSCExchangeModulePath = "$env:Temp\DSCExchangeModuleName"

            Context 'When New-RemoteExchangeSession is called and Exchange is not installed' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-ExchangeSetupComplete -Verifiable -MockWith { return $false }

                    { New-RemoteExchangeSession } | `
                            Should -Throw -ExpectedMessage 'A supported version of Exchange is either not present, or not fully installed on this machine.'
                }
            }

            Context 'When New-RemoteExchangeSession is called and Exchange is installed' {
                It 'Should create and return a PSSession' {
                    Mock -CommandName Test-ExchangeSetupComplete -Verifiable -MockWith { return $true }
                    Mock -CommandName Get-CimInstance -Verifiable -MockWith {
                        return @{
                            Domain = 'contoso.local'
                        }
                    }
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith {
                        return @{
                            MsiInstallPath = 'C:\Program Files\Microsoft\Exchange Server\V15\'
                        }
                    }
                    Mock -CommandName Invoke-DotSourcedScript -Verifiable -MockWith {
                        return @{
                            '_NewExchangeRunspace' = @{
                                Name = 'NewSession'
                            }
                        }
                    }

                    New-RemoteExchangeSession | Should -Be -Not $null
                }
            }
        }

        Describe 'xExchangeHelper\Import-RemoteExchangeModule' -Tag 'Helper' {
            # Override functions which have non-Mockable parameter types
            function Export-PSSession
            {
                param(
                    $OutputModule
                )
            }
            function Import-Module
            {
                param(
                    $Function
                )
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $script:DSCExchangeModuleName = 'DSCExchangeModule'
            $script:DSCExchangeModulePath = "$env:Temp\DSCExchangeModuleName"
            $commandToLoad = 'Get-ExchangeServer'
            $commandsToLoad = @($commandToLoad)

            Context 'When Import-RemoteExchangeModule is called and CommandsToLoad is passed' {
                It 'Should import the session and load the commands' {
                    Mock `
                        -CommandName Export-PSSession `
                        -Verifiable `
                        -ParameterFilter { $OutputModule -eq $script:DSCExchangeModulePath }
                    Mock `
                        -CommandName Import-Module `
                        -ParameterFilter { $Function.Count -eq 1 -and $Function[0] -like $commandToLoad } `
                        -Verifiable

                    Import-RemoteExchangeModule -Session 'SomeSession' -CommandsToLoad $commandsToLoad
                }
            }

            Context 'When Import-RemoteExchangeModule is called and CommandsToLoad is not passed' {
                It 'Should import the session and load all commands' {
                    Mock `
                        -CommandName Export-PSSession `
                        -Verifiable `
                        -ParameterFilter { $OutputModule -eq $script:DSCExchangeModulePath }
                    Mock `
                        -CommandName Import-Module `
                        -ParameterFilter { $Function.Count -eq 1 -and $Function[0] -eq '*' } `
                        -Verifiable

                    Import-RemoteExchangeModule -Session 'SomeSession'
                }
            }
        }

        Describe 'xExchangeHelper\Remove-RemoteExchangeModule' -Tag 'Helper' {
            # Override functions which have non-Mockable parameter types
            function Remove-PSSession
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Remove-RemoteExchangeModule is called' {
                It 'Should remove the module' {
                    Mock -CommandName Remove-Module -Verifiable

                    Remove-RemoteExchangeModule
                }
            }
        }

        # Describe 'xExchangeHelper\Remove-RemoteExchangeSession' -Tag 'Helper' {
        #     # Override functions which have non-Mockable parameter types
        #     function Remove-PSSession
        #     {
        #     }

        #     AfterEach {
        #         Assert-VerifiableMock
        #     }

        #     Context 'When Remove-RemoteExchangeSession is called' {
        #         It 'Should remove the session' {
        #             Mock -CommandName Remove-PSSession -Verifiable

        #             Remove-RemoteExchangeSession
        #         }
        #     }
        # }
        # Describe 'xExchangeHelper\Remove-RemoteExchangeSession' -Tag 'Helper' {
        #     # Override functions which have non-Mockable parameter types
        #     function Remove-PSSession {}
        #     AfterEach {
        #         Assert-VerifiableMock
        #     }
        #     Context 'When Remove-RemoteExchangeSession is called and sessions exist' {
        #         It 'Should remove the sessions' {
        #             Mock -CommandName Get-ExistingRemoteExchangeSession -Verifiable -MockWith { return 'SomeSession' }
        #             Mock -CommandName Remove-PSSession -Verifiable
        #             Remove-RemoteExchangeSession
        #         }
        #     }
        # }

        Describe 'xExchangeHelper\Compare-StringToString' -Tag 'Helper' {
            $trueCaseInsensitiveCases = @(
                @{
                    String1 = 'aBc'
                    String2 = 'AbC'
                }
                @{
                    String1 = 'abc'
                    String2 = 'Abc'
                }
                @{
                    String1 = ''
                    String2 = ''
                }
                @{
                    String1 = ''
                    String2 = $null
                }
                @{
                    String1 = $null
                    String2 = $null
                }
            )

            Context 'When Compare-StringToString is called with the Ignore case switch and the strings are like each other' {
                It 'Should return true' -TestCases $trueCaseInsensitiveCases {
                    param
                    (
                        [System.String]
                        $String1,

                        [System.String]
                        $String2
                    )

                    Compare-StringToString -String1 $String1 -String2 $String2 -IgnoreCase | Should -Be $true
                }
            }

            $trueCaseSensitiveCases = @(
                @{
                    String1 = 'ABC'
                    String2 = 'ABC'
                }
                @{
                    String1 = 'abc'
                    String2 = 'abc'
                }
            )

            Context 'When Compare-StringToString is called without the Ignore case switch and the strings are equal to each other' {
                It 'Should return true' -TestCases $trueCaseSensitiveCases {
                    param
                    (
                        [System.String]
                        $String1,

                        [System.String]
                        $String2
                    )

                    Compare-StringToString -String1 $String1 -String2 $String2 | Should -Be $true
                }
            }

            $falseCaseInsensitiveCases = @(
                @{
                    String1 = 'aBcd'
                    String2 = 'AbC'
                }
                @{
                    String1 = 'abcd'
                    String2 = 'Abc'
                }
            )

            Context 'When Compare-StringToString is called with the Ignore case switch and the strings are not like each other' {
                It 'Should return false' -TestCases $falseCaseInsensitiveCases {
                    param
                    (
                        [System.String]
                        $String1,

                        [System.String]
                        $String2
                    )

                    Compare-StringToString -String1 $String1 -String2 $String2 -IgnoreCase | Should -Be $false
                }
            }

            $falseCaseSensitiveCases = @(
                @{
                    String1 = 'abc'
                    String2 = 'ABC'
                }
            )

            Context 'When Compare-StringToString is called without the Ignore case switch and the strings are not equal to each other' {
                It 'Should return false' -TestCases $falseCaseSensitiveCases {
                    param
                    (
                        [System.String]
                        $String1,

                        [System.String]
                        $String2
                    )

                    Compare-StringToString -String1 $String1 -String2 $String2 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Compare-BoolToBool' -Tag 'Helper' {
            $trueBooleanTestCases = @(
                @{
                    Bool1 = $true
                    Bool2 = $true
                }
                @{
                    Bool1 = $false
                    Bool2 = $false
                }
                @{
                    Bool1 = $null
                    Bool2 = $false
                }
                @{
                    Bool1 = $false
                    Bool2 = $null
                }
            )

            Context 'When Compare-BoolToBool is called and both Booleans are like each other' {
                It 'Should return true' -TestCases $trueBooleanTestCases {
                    param
                    (
                        [Nullable[System.Boolean]]
                        $Bool1,

                        [Nullable[System.Boolean]]
                        $Bool2
                    )

                    Compare-BoolToBool -Bool1 $Bool1 -Bool2 $Bool2 | Should -Be $true
                }
            }

            $falseBooleanTestCases = @(
                @{
                    Bool1 = $true
                    Bool2 = $false
                }
                @{
                    Bool1 = $false
                    Bool2 = $true
                }
                @{
                    Bool1 = $true
                    Bool2 = $null
                }
                @{
                    Bool1 = $null
                    Bool2 = $true
                }
            )

            Context 'When Compare-BoolToBool is called and both Booleans are not like each other' {
                It 'Should return false' -TestCases $falseBooleanTestCases {
                    param
                    (
                        [Nullable[System.Boolean]]
                        $Bool1,

                        [Nullable[System.Boolean]]
                        $Bool2
                    )

                    Compare-BoolToBool -Bool1 $Bool1 -Bool2 $Bool2 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Compare-UnlimitedToString' -Tag 'Helper' {
            # Override functions which have non-Mockable parameter types
            function Compare-ByteQuantifiedSizeToString
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $unlimitedUnlimited = @{
                IsUnlimited = $true
            }

            Context 'When Compare-UnlimitedToString is called and the Unlimited is set to Unlimited' {
                It 'Should call Compare-StringToString, passing Unlimited as the first string, and the input string as the second' {
                    Mock `
                        -CommandName Compare-StringToString `
                        -ParameterFilter { $String2 -eq 'unlimitedUnlimitedComp' } `
                        -Verifiable `
                        -MockWith { return $true }

                    Compare-UnlimitedToString -Unlimited $unlimitedUnlimited -String 'unlimitedUnlimitedComp'
                }
            }

            $unlimitedInt32 = @{
                IsUnlimited = $false
                Value       = [System.Int32] 1
            }

            Context 'When Compare-UnlimitedToString is called, the Unlimited is not set to Unlimited, and the string equals Unlimited' {
                It 'Should return false' {
                    Mock -CommandName Compare-StringToString -ParameterFilter { $String2 -eq 'Unlimited' } -Verifiable -MockWith { return $true }

                    Compare-UnlimitedToString -Unlimited $unlimitedInt32 -String 'Unlimited' | Should -Be $false
                }
            }

            Context 'When Compare-UnlimitedToString is called, the Unlimited is not set to Unlimited, and the Unlimited Value is an Int32' {
                It 'Should call Compare-StringToString, passing the Unlimited value as the first string, and the input string as the second' {
                    Mock `
                        -CommandName Compare-StringToString `
                        -ParameterFilter { $String1 -eq $unlimitedInt32.Value.ToString() -and $String2 -eq '2' } `
                        -Verifiable `
                        -MockWith { return $true }

                    Compare-UnlimitedToString -Unlimited $unlimitedInt32 -String '2'
                }
            }

            $unlimitedOther = @{
                IsUnlimited = $false
            }

            Context 'When Compare-UnlimitedToString is called, the Unlimited is not set to Unlimited, and the Unlimited Value is not an Int32' {
                It 'Should call Compare-ByteQuantifiedSizeToString' {
                    Mock -CommandName Compare-StringToString -Verifiable -MockWith { return $false }
                    Mock -CommandName Compare-ByteQuantifiedSizeToString -Verifiable

                    Compare-UnlimitedToString -Unlimited $unlimitedOther -String '2'
                }
            }
        }

        Describe 'xExchangeHelper\Convert-StringToArray' -Tag 'Helper' {
            Context 'When Convert-StringToArray is called, the string does not contain the separator, and does not contain whitespace' {
                It 'Should return the same string' {
                    $outputArray = Convert-StringToArray -StringIn 'Test' -Separator ','

                    $outputArray.Count -eq 1 -and $outputArray[0] -ceq 'Test'
                }
            }

            Context 'When Convert-StringToArray is called, the string does not contain the separator, and does contains whitespace' {
                It 'Should return the string without whitespace' {
                    $outputArray = Convert-StringToArray -StringIn ' Test ' -Separator ','

                    $outputArray.Count -eq 1 -and $outputArray[0] -ceq 'Test'
                }
            }

            Context 'When Convert-StringToArray is called, the string contains a separator, and substrings have a mix of whitespace and no whitespace' {
                It 'Should return the split, trimmed strings' {
                    $outputArray = Convert-StringToArray -StringIn 'Abc, deF, ghi ,jkl ,mno' -Separator ','

                    $outputArray.Count | Should -Be 5
                    $outputArray.Contains('Abc') | Should -Be $true
                    $outputArray.Contains('deF') | Should -Be $true
                    $outputArray.Contains('ghi') | Should -Be $true
                    $outputArray.Contains('jkl') | Should -Be $true
                    $outputArray.Contains('mno') | Should -Be $true
                }
            }

            Context 'When Convert-StringToArray is called with a null string' {
                It 'Should return an array with 1 empty string' {
                    $outputArray = Convert-StringToArray -StringIn $null -Separator ','

                    $outputArray.Count -eq 1 -and [String]::IsNullOrEmpty($outputArray[0]) | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Convert-StringArrayToLowerCase' -Tag 'Helper' {
            Context 'When Convert-StringArrayToLowerCase is called' {
                It 'All input array members show be converted to lower case, and null members should be converted to empty strings' {
                    [System.String[]] $inputArray = @('ABC', 'dEf', $null, 'GhI', 'jkl', '', 'mnO')

                    $outputArray = Convert-StringArrayToLowerCase -Array $inputArray

                    $outputArray.Count | Should -Be 7
                    $outputArray.Contains('abc') | Should -Be $true
                    $outputArray.Contains('def') | Should -Be $true
                    $outputArray.Contains('ghi') | Should -Be $true
                    $outputArray.Contains('jkl') | Should -Be $true
                    $outputArray.Contains('mno') | Should -Be $true

                    $outputArray[2] | Should -Be ''
                    $outputArray[5] | Should -Be ''
                }
            }
        }

        Describe 'xExchangeHelper\Compare-ArrayContent' -Tag 'Helper' {
            $trueCaseInsensitiveCases = @(
                @{
                    Array1Param = @('aBc', '', 'deF')
                    Array1Lower = @('abc', '', 'def')
                    Array2Param = @('', 'DEF', 'AbC')
                    Array2Lower = @('', 'def', 'abc')
                }
                @{
                    Array1Param = @()
                    Array1Lower = @()
                    Array2Param = @()
                    Array2Lower = @()
                }
                @{
                    Array1Param = @('abc', 'def')
                    Array1Lower = @('abc', 'def')
                    Array2Param = @('abc', 'def')
                    Array2Lower = @('abc', 'def')
                }
            )

            Context 'When Compare-ArrayContent is called with IgnoreCase and the arrays contain the same contents' {
                It 'Should return true' -TestCases $trueCaseInsensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1Param,

                        [System.String[]]
                        $Array1Lower,

                        [System.String[]]
                        $Array2Param,

                        [System.String[]]
                        $Array2Lower
                    )

                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array1Param -DifferenceObject $Array1 ) } `
                        -Verifiable `
                        -MockWith { return $Array1Lower }
                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array2Param -DifferenceObject $Array2 ) } `
                        -Verifiable `
                        -MockWith { return $Array2Lower }

                    Compare-ArrayContent -Array1 $Array1Param -Array2 $Array2Param -IgnoreCase | Should -Be $true
                }
            }

            $falseCaseInsensitiveCases = @(
                @{
                    Array1Param = @('aBc', '', 'deF')
                    Array1Lower = @('abc', '', 'def')
                    Array2Param = @('DEF', 'AbC')
                    Array2Lower = @('def', 'abc')
                }
                @{
                    Array1Param = @()
                    Array1Lower = @()
                    Array2Param = @('')
                    Array2Lower = @('')
                }
                @{
                    Array1Param = @('abc', 'def')
                    Array1Lower = @('abc', 'def')
                    Array2Param = @('abc', 'def', 'GHI')
                    Array2Lower = @('abc', 'def', 'ghi')
                }
            )

            Context 'When Compare-ArrayContent is called with IgnoreCase and the arrays do not contain the same contents' {
                It 'Should return false' -TestCases $falseCaseInsensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1Param,

                        [System.String[]]
                        $Array1Lower,

                        [System.String[]]
                        $Array2Param,

                        [System.String[]]
                        $Array2Lower
                    )

                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array1Param -DifferenceObject $Array1 ) } `
                        -Verifiable `
                        -MockWith { return $Array1Lower }
                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array2Param -DifferenceObject $Array2 ) } `
                        -Verifiable `
                        -MockWith { return $Array2Lower }

                    Compare-ArrayContent -Array1 $Array1Param -Array2 $Array2Param -IgnoreCase | Should -Be $false
                }
            }

            $trueCaseSensitiveCases = @(
                @{
                    Array1 = @('aBc', '', 'deF')
                    Array2 = @('', 'aBc', 'deF')
                }
                @{
                    Array1 = @()
                    Array2 = @()
                }
                @{
                    Array1 = @('abc', 'def')
                    Array2 = @('def', 'abc')
                }
            )

            Context 'When Compare-ArrayContent is called without IgnoreCase and the arrays contain the same contents' {
                It 'Should return true' -TestCases $trueCaseSensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1,

                        [System.String[]]
                        $Array2
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase

                    Compare-ArrayContent -Array1 $Array1 -Array2 $Array2 | Should -Be $true

                    Assert-MockCalled Convert-StringArrayToLowerCase -Times 0
                }
            }

            $falseCaseSensitiveCases = @(
                @{
                    Array1 = @('aBc', '', 'deF')
                    Array2 = @('aBc', 'deF')
                }
                @{
                    Array1 = @('')
                    Array2 = @()
                }
                @{
                    Array1 = @('abc', 'def')
                    Array2 = @('ABC', 'DEF')
                }
                @{
                    Array1 = @('abc', 'def')
                    Array2 = @('DEF', 'abc')
                }
            )

            Context 'When Compare-ArrayContent is called without IgnoreCase and the arrays do not contain the same contents' {
                It 'Should return false' -TestCases $falseCaseSensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1,

                        [System.String[]]
                        $Array2
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase

                    Compare-ArrayContent -Array1 $Array1 -Array2 $Array2 | Should -Be $false

                    Assert-MockCalled Convert-StringArrayToLowerCase -Times 0
                }
            }
        }

        Describe 'xExchangeHelper\Test-ArrayElementsInSecondArray' -Tag 'Helper' {
            $trueCaseInsensitiveCases = @(
                @{
                    Array1Param = @('aBc', '', 'deF')
                    Array1Lower = @('abc', '', 'def')
                    Array2Param = @('', 'DEF', 'AbC')
                    Array2Lower = @('', 'def', 'abc')
                }
                @{
                    Array1Param = @()
                    Array1Lower = @()
                    Array2Param = @()
                    Array2Lower = @()
                }
                @{
                    Array1Param = @()
                    Array1Lower = @()
                    Array2Param = @('ABC')
                    Array2Lower = @('abc')
                }
                @{
                    Array1Param = @('abc', 'def')
                    Array1Lower = @('abc', 'def')
                    Array2Param = @('abc', 'GHI', 'def')
                    Array2Lower = @('abc', 'ghi', 'def')
                }
            )

            Context 'When Test-ArrayElementsInSecondArray is called with IgnoreCase and the arrays contain the same contents' {
                It 'Should return true' -TestCases $trueCaseInsensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1Param,

                        [System.String[]]
                        $Array1Lower,

                        [System.String[]]
                        $Array2Param,

                        [System.String[]]
                        $Array2Lower
                    )

                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array1Param -DifferenceObject $Array1 ) } `
                        -Verifiable `
                        -MockWith { return $Array1Lower }
                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array2Param -DifferenceObject $Array2 ) } `
                        -Verifiable `
                        -MockWith { return $Array2Lower }

                    Test-ArrayElementsInSecondArray -Array1 $Array1Param -Array2 $Array2Param -IgnoreCase | Should -Be $true
                }
            }

            $falseCaseInsensitiveCases = @(
                @{
                    Array1Param = @('ABC')
                    Array1Lower = @('abc')
                    Array2Param = @()
                    Array2Lower = @()
                }
                @{
                    Array1Param = @('abc', 'GHI', 'def')
                    Array1Lower = @('abc', 'ghi', 'def')
                    Array2Param = @('abc', 'def')
                    Array2Lower = @('abc', 'def')
                }
            )

            Context 'When Test-ArrayElementsInSecondArray is called with IgnoreCase and the arrays do not contain the same contents' {
                It 'Should return false' -TestCases $falseCaseInsensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1Param,

                        [System.String[]]
                        $Array1Lower,

                        [System.String[]]
                        $Array2Param,

                        [System.String[]]
                        $Array2Lower
                    )

                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array1Param -DifferenceObject $Array1 ) } `
                        -Verifiable `
                        -MockWith { return $Array1Lower }
                    Mock `
                        -CommandName Convert-StringArrayToLowerCase `
                        -ParameterFilter { $null -eq (Compare-Object -ReferenceObject $Array2Param -DifferenceObject $Array2 ) } `
                        -Verifiable `
                        -MockWith { return $Array2Lower }

                    Test-ArrayElementsInSecondArray -Array1 $Array1Param -Array2 $Array2Param -IgnoreCase | Should -Be $false
                }
            }

            $trueCaseSensitiveCases = @(
                @{
                    Array1 = @('aBc', '', 'deF')
                    Array2 = @('', 'aBc', 'deF')
                }
                @{
                    Array1 = @()
                    Array2 = @()
                }
                @{
                    Array1 = @('abc', 'def')
                    Array2 = @('def', 'abc', '', 'GHI')
                }
            )

            Context 'When Test-ArrayElementsInSecondArray is called without IgnoreCase and the arrays contain the same contents' {
                It 'Should return true' -TestCases $trueCaseSensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1,

                        [System.String[]]
                        $Array2
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase

                    Test-ArrayElementsInSecondArray -Array1 $Array1 -Array2 $Array2 | Should -Be $true

                    Assert-MockCalled Convert-StringArrayToLowerCase -Times 0
                }
            }

            $falseCaseSensitiveCases = @(
                @{
                    Array1 = @('aBc', '', 'deF')
                    Array2 = @('', 'ABC', 'deF')
                }
                @{
                    Array1 = @('ABC')
                    Array2 = @('abc')
                }
                @{
                    Array1 = @('def', 'abc', '', 'GHI')
                    Array2 = @('abc', 'def')
                }
            )

            Context 'When Test-ArrayElementsInSecondArray is called without IgnoreCase and the arrays do not contain the same contents' {
                It 'Should return true' -TestCases $falseCaseSensitiveCases {
                    param
                    (
                        [System.String[]]
                        $Array1,

                        [System.String[]]
                        $Array2
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase

                    Test-ArrayElementsInSecondArray -Array1 $Array1 -Array2 $Array2 | Should -Be $false

                    Assert-MockCalled Convert-StringArrayToLowerCase -Times 0
                }
            }
        }

        Describe 'xExchangeHelper\Add-ToPSBoundParametersFromHashtable' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Add-ToPSBoundParametersFromHashtable is called, a parameter is added, and a parameter is changed' {
                It 'Should add a new parameter and change the existing parameter' {
                    $param1 = 'abc'
                    $param2 = $null
                    $param2new = 'notnull'
                    $param3 = 'def'
                    $param4 = 'ghi'

                    $psBoundParametersIn = @{
                        Param1 = $param1
                        Param2 = $param2
                        Param3 = $param3
                    }

                    $paramsToAdd = @{
                        Param2 = $param2new
                        Param4 = $param4
                    }

                    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $psBoundParametersIn -ParamsToAdd $paramsToAdd

                    $psBoundParametersIn.ContainsKey('Param1') -and $psBoundParametersIn['Param1'] -eq $param1 | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param2') -and $psBoundParametersIn['Param2'] -eq $param2new | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param3') -and $psBoundParametersIn['Param3'] -eq $param3 | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param4') -and $psBoundParametersIn['Param4'] -eq $param4 | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Remove-FromPSBoundParametersUsingHashtable' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Remove-FromPSBoundParametersUsingHashtable is called and both ParamsToKeep and ParamsToRemove are specified' {
                It 'Should throw an exception' {
                    { Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn @{ } -ParamsToKeep @('Param1') -ParamsToRemove @('Param2') } | `
                            Should -Throw -ExpectedMessage 'Remove-FromPSBoundParametersUsingHashtable does not support using both ParamsToKeep and ParamsToRemove'
                }
            }

            Context 'When Remove-FromPSBoundParametersUsingHashtable is called with ParamsToKeep' {
                It 'Should remove any parameter not specified in ParamsToKeep' {
                    Mock -CommandName Convert-StringArrayToLowerCase -Verifiable -MockWith { return @('param1', 'param2') }

                    $psBoundParametersIn = @{
                        Param1 = 1
                        Param2 = 2
                        Param3 = 3
                    }

                    $paramsToKeep = @('Param1', 'Param2')

                    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $psBoundParametersIn -ParamsToKeep $paramsToKeep

                    $psBoundParametersIn.ContainsKey('Param1') | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param2') | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param3') | Should -Be $false
                }
            }

            Context 'When Remove-FromPSBoundParametersUsingHashtable is called with ParamsToRemove' {
                It 'Should remove any parameter specified in ParamsToRemove' {
                    $psBoundParametersIn = @{
                        Param1 = 1
                        Param2 = 2
                        Param3 = 3
                    }

                    $paramsToRemove = @(
                        'Param1',
                        'param2'
                    )

                    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $psBoundParametersIn -ParamsToRemove $paramsToRemove

                    $psBoundParametersIn.ContainsKey('Param1') | Should -Be $false
                    $psBoundParametersIn.ContainsKey('Param2') | Should -Be $false
                    $psBoundParametersIn.ContainsKey('Param3') | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Remove-NotApplicableParamsForVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Remove-NotApplicableParamsForVersion is called and the parameter exists in the current Exchange version' {
                It 'Should not modify the input PSBoundParameters' {
                    Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith {
                        return '2016'
                    }

                    $psBoundParametersIn = @{
                        Param1 = 1
                        Param2 = 2
                        Param3 = 3
                    }

                    Remove-NotApplicableParamsForVersion `
                        -PSBoundParametersIn $psBoundParametersIn `
                        -ParamName 'Param1' `
                        -ResourceName 'xExchangeHelper.tests.ps1' `
                        -ParamExistsInVersion @('2016', '2019')

                    $psBoundParametersIn.ContainsKey('Param1') | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param2') | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param3') | Should -Be $true
                }
            }

            Context 'When Remove-NotApplicableParamsForVersion is called and the parameter does not exist in the current Exchange version' {
                It 'Should remove the parameter from the input PSBoundParameters, but leave the other parameters' {
                    Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith {
                        return '2016'
                    }
                    Mock -CommandName Write-Warning -Verifiable

                    $psBoundParametersIn = @{
                        Param1 = 1
                        Param2 = 2
                        Param3 = 3
                    }

                    Remove-NotApplicableParamsForVersion `
                        -PSBoundParametersIn $psBoundParametersIn `
                        -ParamName 'Param1' `
                        -ResourceName 'xExchangeHelper.tests.ps1' `
                        -ParamExistsInVersion @('2013', '2019')

                    $psBoundParametersIn.ContainsKey('Param1') | Should -Be $false
                    $psBoundParametersIn.ContainsKey('Param2') | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param3') | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Set-EmptyStringParamsToNull' -Tag 'Helper' {
            Context 'When Set-EmptyStringParamsToNull is called and the input hashtable contains empty strings' {
                It 'Should set the empty strings to null and not modify any other parameters' {
                    $psBoundParametersIn = @{
                        Param1 = 1
                        Param2 = ''
                        Param3 = 'abc'
                        Param4 = $null
                    }

                    Set-EmptyStringParamsToNull -PSBoundParametersIn $psBoundParametersIn

                    $psBoundParametersIn.ContainsKey('Param1') -and $psBoundParametersIn['Param1'] -eq 1 | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param2') -and $psBoundParametersIn['Param2'] -eq $null | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param3') -and $psBoundParametersIn['Param3'] -eq 'abc' | Should -Be $true
                    $psBoundParametersIn.ContainsKey('Param4') -and $psBoundParametersIn['Param4'] -eq $null | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Write-InvalidSettingVerbose' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Write-InvalidSettingVerbose is called' {
                It 'Should call Write-Verbose, and the message should contain the input values' {
                    $setting = 'TestSetting'
                    $expected = 'ExpectedTestValue'
                    $actual = 'ActualTestValue'

                    Mock -CommandName Write-Verbose -ParameterFilter { $Message.Contains($setting) -and $Message.Contains($expected) -and $Message.Contains($actual) } -Verifiable

                    Write-InvalidSettingVerbose -SettingName $setting -ExpectedValue $expected -ActualValue $actual
                }
            }
        }

        Describe 'xExchangeHelper\Write-FunctionEntry' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $functionName = 'Test-Function'

            Context 'When Write-FunctionEntry is called without parameters' {
                It 'Should write the calling function name and no parameters' {
                    Mock -CommandName Get-PSCallStack -Verifiable -MockWith {
                        return @(
                            @{FunctionName = 'Bottom-O-Stack' },
                            @{FunctionName = $functionName }
                        )
                    }
                    Mock -CommandName Write-Verbose -ParameterFilter { $Message.Contains($functionName) -and !$Message.Contains('parameters') } -Verifiable

                    Write-FunctionEntry
                }
            }

            Context 'When Write-FunctionEntry is called with parameters' {
                It 'Should write the calling function name and parameters' {
                    Mock -CommandName Get-PSCallStack -Verifiable -MockWith {
                        return @(
                            @{FunctionName = 'Bottom-O-Stack' },
                            @{FunctionName = $functionName }
                        )
                    }
                    Mock `
                        -CommandName Write-Verbose `
                        -ParameterFilter { $Message.Contains($functionName) -and $Message.Contains('Param1') -and $Message.Contains('123') -and $Message.Contains('Param2') -and $Message.Contains('321') } `
                        -Verifiable

                    Write-FunctionEntry -Parameters @{Param1 = 123; Param2 = 321 }
                }
            }
        }

        Describe 'xExchangeHelper\Test-CmdletHasParameter' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-CmdletHasParameter is called and the cmdlet has the input parameter' {
                It 'Should return true' {
                    $targetParam = 'TestParam'

                    Mock -CommandName Get-Command -Verifiable -MockWith {
                        return @{
                            Parameters = @{
                                $targetParam = 1
                            }
                        }
                    }

                    Test-CmdletHasParameter -CmdletName 'TestCmdlet' -ParameterName $targetParam | Should -Be $true
                }
            }

            Context 'When Test-CmdletHasParameter is called and the cmdlet does not have the input parameter' {
                It 'Should return false' {
                    $targetParam = 'TestParam'

                    Mock -CommandName Get-Command -Verifiable -MockWith {
                        return @{
                            Parameters = @{
                                SomeOtherParam = 1
                            }
                        }
                    }

                    Test-CmdletHasParameter -CmdletName 'TestCmdlet' -ParameterName $targetParam | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetting' -Tag 'Helper' {
            # Override functions that require types loaded by Exchange DLLs
            function Compare-TimespanToString
            {
            }
            function Compare-ByteQuantifiedSizeToString
            {
            }
            function Compare-SmtpAddressToString
            {
            }
            function Compare-PSCredential
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ExchangeSetting is called and the target type is not handled by the function' {
                It 'Should throw an exception' {
                    { Test-ExchangeSetting -Name 'Setting' -Type 'MissingType' -ExpectedValue 1 -ActualValue 2 -PSBoundParametersIn @{Setting = 1 } } | `
                            Should -Throw -ExpectedMessage 'Type not found: MissingType'
                }
            }

            $simpleTypeFunctionComparisons = @(
                @{
                    Type     = 'String'
                    Function = 'Compare-StringToString'
                },
                @{
                    Type     = 'Boolean'
                    Function = 'Compare-BoolToBool'
                },
                @{
                    Type     = 'Array'
                    Function = 'Compare-ArrayContent'
                },
                @{
                    Type     = 'Unlimited'
                    Function = 'Compare-UnlimitedToString'
                },
                @{
                    Type     = 'Timespan'
                    Function = 'Compare-TimespanToString'
                },
                @{
                    Type     = 'ADObjectID'
                    Function = 'Compare-ADObjectIdToSmtpAddressString'
                },
                @{
                    Type     = 'ByteQuantifiedSize'
                    Function = 'Compare-ByteQuantifiedSizeToString'
                },
                @{
                    Type     = 'IPAddress'
                    Function = 'Compare-IPAddressToString'
                },
                @{
                    Type     = 'IPAddresses'
                    Function = 'Compare-IPAddressesToArray'
                },
                @{
                    Type     = 'SMTPAddress'
                    Function = 'Compare-SmtpAddressToString'
                },
                @{
                    Type     = 'PSCredential'
                    Function = 'Compare-PSCredential'
                }
            )

            Context 'When Test-ExchangeSetting is called and the results are determined by a call to simple function, when the function returns true' {
                It 'Should return true' -TestCases $simpleTypeFunctionComparisons {
                    param
                    (
                        [System.String]
                        $Type,

                        [System.String]
                        $Function
                    )

                    Mock -CommandName $Function -Verifiable -MockWith { return $true }

                    Test-ExchangeSetting -Name 'Setting' -Type $Type -ExpectedValue 1 -ActualValue 2 -PSBoundParametersIn @{Setting = 1 } | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetting is called and the results are determined by a call to simple function, when the function returns false' {
                It 'Should return false' -TestCases $simpleTypeFunctionComparisons {
                    param
                    (
                        [System.String]
                        $Type,

                        [System.String]
                        $Function
                    )

                    Mock -CommandName $Function -Verifiable -MockWith { return $false }
                    Mock -CommandName Write-InvalidSettingVerbose -Verifiable

                    Test-ExchangeSetting -Name 'Setting' -Type $Type -ExpectedValue 1 -ActualValue 2 -PSBoundParametersIn @{Setting = 1 } | Should -Be $false
                }
            }

            Context 'When Test-ExchangeSetting is called, the Type is Int, and the types are equal' {
                It 'Should return true' {
                    Test-ExchangeSetting -Name 'Setting' -Type 'Int' -ExpectedValue 1 -ActualValue 1 -PSBoundParametersIn @{Setting = 1 } | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetting is called, the Type is Int, and the types are not equal' {
                It 'Should return false' {
                    Mock -CommandName Write-InvalidSettingVerbose -Verifiable

                    Test-ExchangeSetting -Name 'Setting' -Type 'Int' -ExpectedValue 1 -ActualValue 2 -PSBoundParametersIn @{Setting = 1 } | Should -Be $false
                }
            }

            Context 'When Test-ExchangeSetting is called, the Type is ExtendedProtection, the ExpectedValue array contains "none", and the ActualValue is empty' {
                It 'Should return true' {
                    Mock -CommandName Convert-StringArrayToLowerCase -Verifiable -MockWith { return @('none') }

                    Test-ExchangeSetting -Name 'Setting' -Type 'ExtendedProtection' -ExpectedValue 1 -ActualValue '' -PSBoundParametersIn @{Setting = 1 } | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetting is called, the Type is ExtendedProtection, the ExpectedValue array contains "none", and the ActualValue is not empty' {
                It 'Should return false' {
                    Mock -CommandName Convert-StringArrayToLowerCase -Verifiable -MockWith { return @('none') }
                    Mock -CommandName Write-InvalidSettingVerbose -Verifiable

                    Test-ExchangeSetting -Name 'Setting' -Type 'ExtendedProtection' -ExpectedValue 1 -ActualValue 'notempty' -PSBoundParametersIn @{Setting = 1 } | Should -Be $false
                }
            }

            Context 'When Test-ExchangeSetting is called, the Type is ExtendedProtection, the ExpectedValue array does not contain "none", and Compare-ArrayContent returns true' {
                It 'Should return true' {
                    Mock -CommandName Compare-ArrayContent -Verifiable -MockWith { return $true }

                    Test-ExchangeSetting -Name 'Setting' -Type 'ExtendedProtection' -ExpectedValue 1 -ActualValue '' -PSBoundParametersIn @{Setting = 1 } | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetting is called, the Type is ExtendedProtection, the ExpectedValue array does not contain "none", and Compare-ArrayContent returns false' {
                It 'Should return false' {
                    Mock -CommandName Compare-ArrayContent -Verifiable -MockWith { return $false }
                    Mock -CommandName Write-InvalidSettingVerbose -Verifiable

                    Test-ExchangeSetting -Name 'Setting' -Type 'ExtendedProtection' -ExpectedValue 1 -ActualValue '' -PSBoundParametersIn @{Setting = 1 } | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Compare-IPAddressToString' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $nullNotNullComparisons = @(
                @{
                    IPAddress = $null
                    String    = '192.168.0.1'
                },
                @{
                    IPAddress = [System.Net.IPAddress] '192.168.1.1'
                    String    = $null
                },
                @{
                    IPAddress = [System.Net.IPAddress] '192.168.1.1'
                    String    = ''
                }
            )

            Context 'When Compare-IPAddressToString is called, the IPAddress is null and the string is not, or vice versa' {
                It 'Should return false' -TestCases $nullNotNullComparisons {
                    param
                    (
                        [System.Net.IPAddress]
                        $IPAddress,

                        [System.String]
                        $String
                    )

                    Compare-IPAddressToString -IPAddress $IPAddress -String $String | Should -Be $false
                }
            }

            $nullNullComparisons = @(
                @{
                    IPAddress = $null
                    String    = ''
                },
                @{
                    IPAddress = $null
                    String    = $null
                }
            )

            Context 'When Compare-IPAddressToString is called, the IPAddress is null and the string is null or empty' {
                It 'Should return true' -TestCases $nullNullComparisons {
                    param
                    (
                        [System.Net.IPAddress]
                        $IPAddress,

                        [System.String]
                        $String
                    )

                    Compare-IPAddressToString -IPAddress $IPAddress -String $String | Should -Be $true
                }
            }

            $actualIPToStringComps = @(
                @{
                    IPAddress = [System.Net.IPAddress] '192.168.1.1'
                    String    = '192.168.1.1'
                    Result    = $true
                },
                @{
                    IPAddress = [System.Net.IPAddress] '192.168.1.1'
                    String    = '192.168.01.01'
                    Result    = $true
                },
                @{
                    IPAddress = [System.Net.IPAddress] '192.168.1.2'
                    String    = '192.168.1.1'
                    Result    = $false
                }
            )

            Context 'When Compare-IPAddressToString is called and the IPAddress and string are not empty' {
                It 'Should compare properly' -TestCases $actualIPToStringComps {
                    param
                    (
                        [System.Net.IPAddress]
                        $IPAddress,

                        [System.String]
                        $String,

                        [System.Boolean]
                        $Result
                    )

                    Compare-IPAddressToString -IPAddress $IPAddress -String $String | Should -Be $Result
                }
            }
        }

        Describe 'xExchangeHelper\Compare-IPAddressesToArray' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $trueIPAddressArrayComps = @(
                @{
                    IPAddressObjects = @(
                        [System.Net.IPAddress] '192.168.1.1',
                        [System.Net.IPAddress] '192.168.1.2'
                    )
                    IPAddressStrings = @(
                        '192.168.1.1'
                        '192.168.1.2'
                    )
                },
                @{
                    IPAddressObjects = @(
                        [System.Net.IPAddress] '192.168.1.1',
                        [System.Net.IPAddress] '192.168.1.2'
                    )
                    IPAddressStrings = @(
                        '192.168.1.02'
                        '192.168.01.1'
                    )
                },
                @{
                    IPAddressObjects = @()
                    IPAddressStrings = @()
                }
            )

            Context 'When Compare-IPAddressesToArray is called and the IPAddress and String arrays contain similar contents' {
                It 'Should return true' -TestCases $trueIPAddressArrayComps {
                    param
                    (
                        [System.Net.IPAddress[]]
                        $IPAddressObjects,

                        [System.String[]]
                        $IPAddressStrings
                    )

                    Compare-IPAddressesToArray -IPAddressObjects $IPAddressObjects -IPAddressStrings $IPAddressStrings | Should -Be $true
                }
            }

            $falseIPAddressArrayComps = @(
                @{
                    IPAddressObjects = @(
                        [System.Net.IPAddress] '192.168.1.1',
                        [System.Net.IPAddress] '192.168.1.2'
                    )
                    IPAddressStrings = @(
                        '192.168.1.1'
                    )
                },
                @{
                    IPAddressObjects = @(
                        [System.Net.IPAddress] '192.168.1.1',
                        [System.Net.IPAddress] '192.168.1.2'
                    )
                    IPAddressStrings = @(
                        '192.168.1.03'
                        '192.168.01.4'
                    )
                },
                @{
                    IPAddressObjects = @(
                        [System.Net.IPAddress] '192.168.1.1',
                        [System.Net.IPAddress] '192.168.1.2'
                    )
                    IPAddressStrings = @()
                },
                @{
                    IPAddressObjects = @()
                    IPAddressStrings = @(
                        '192.168.1.03'
                        '192.168.01.4'
                    )
                }
            )

            Context 'When Compare-IPAddressesToArray is called and the IPAddress and String arrays do not contain similar contents' {
                It 'Should return false' -TestCases $falseIPAddressArrayComps {
                    param
                    (
                        [System.Net.IPAddress[]]
                        $IPAddressObjects,

                        [System.String[]]
                        $IPAddressStrings
                    )

                    Compare-IPAddressesToArray -IPAddressObjects $IPAddressObjects -IPAddressStrings $IPAddressStrings | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Restart-ExistingAppPool' -Tag 'Helper' {
            # Allow override of IIS commands
            function Get-WebAppPoolState
            {
            }
            function Restart-WebAppPool
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Restart-ExistingAppPool is called and the application pool exists' {
                It 'Should restart the application pool' {
                    Mock -CommandName Get-WebAppPoolState -Verifiable -MockWith { return $true }
                    Mock -CommandName Restart-WebAppPool -Verifiable

                    Restart-ExistingAppPool -Name 'SomeAppPool'
                }
            }

            Context 'When Restart-ExistingAppPool is called and the application pool does not exist' {
                It 'Should not attempt to restart the application pool' {
                    Mock -CommandName Get-WebAppPoolState -Verifiable -MockWith { return $null }
                    Mock -CommandName Restart-WebAppPool

                    Restart-ExistingAppPool -Name 'SomeAppPool'

                    Assert-MockCalled -CommandName Restart-WebAppPool -Times 0
                }
            }
        }

        Describe 'xExchangeHelper\Compare-PSCredential' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $password1 = ConvertTo-SecureString 'Password1' -AsPlainText -Force
            $password1Upper = ConvertTo-SecureString 'PASSWORD1' -AsPlainText -Force

            $user1 = 'user1'
            $user1Upper = 'USER1'
            $user2 = 'user2'

            $trueCredentialComps = @(
                @{
                    Cred1 = New-Object System.Management.Automation.PSCredential ($user1, $password1)
                    Cred2 = New-Object System.Management.Automation.PSCredential ($user1, $password1)
                },
                @{
                    Cred1 = New-Object System.Management.Automation.PSCredential ($user1, $password1)
                    Cred2 = New-Object System.Management.Automation.PSCredential ($user1Upper, $password1)
                },
                @{
                    Cred1 = $null
                    Cred2 = $null
                }
            )

            Context 'When Compare-PSCredential is called and the credentials are equal' {
                It 'Should return true' -TestCases $trueCredentialComps {
                    param
                    (
                        [System.Management.Automation.PSCredential]
                        $Cred1,

                        [System.Management.Automation.PSCredential]
                        $Cred2
                    )

                    Compare-PSCredential -Cred1 $Cred1 -Cred2 $Cred2 | Should -Be $true
                }
            }

            $falseCredentialComps = @(
                @{
                    Cred1 = New-Object System.Management.Automation.PSCredential ($user1, $password1)
                    Cred2 = New-Object System.Management.Automation.PSCredential ($user1, $password1Upper)
                },
                @{
                    Cred1 = New-Object System.Management.Automation.PSCredential ($user1, $password1)
                    Cred2 = New-Object System.Management.Automation.PSCredential ($user2, $password1)
                },
                @{
                    Cred1 = New-Object System.Management.Automation.PSCredential ($user1, $password1)
                    Cred2 = $null
                },
                @{
                    Cred1 = $null
                    Cred2 = New-Object System.Management.Automation.PSCredential ($user2, $password1)
                }
            )

            Context 'When Compare-PSCredential is called and the credentials are not equal' {
                It 'Should return false' -TestCases $falseCredentialComps {
                    param
                    (
                        [System.Management.Automation.PSCredential]
                        $Cred1,

                        [System.Management.Automation.PSCredential]
                        $Cred2
                    )

                    Compare-PSCredential -Cred1 $Cred1 -Cred2 $Cred2 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Start-ExchangeScheduledTask' -Tag 'Helper' {
            # Override functions with non-Mockable parameter types
            function Register-ScheduledTask
            {
            }
            function Set-ScheduledTask
            {
            }
            function Start-ScheduledTask
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $functionArgs = @{
                Path             = 'ExeLocation'
                Arguments        = 'Args'
                Credential       = New-Object System.Management.Automation.PSCredential ('SomeUser', (ConvertTo-SecureString 'Password1' -AsPlainText -Force))
                TaskName         = 'TaskName'
                WorkingDirectory = 'WorkingLocation'
            }

            $taskAction = @{ WorkingDirectory = $functionArgs.WorkingDirectory }

            Context 'When Start-ExchangeScheduledTask is called and no errors are encountered while setting up the task' {
                It 'Should register the task, set settings on it, and start it' {
                    Mock -CommandName New-ScheduledTaskAction -Verifiable -MockWith { return $taskAction }
                    Mock -CommandName Get-PreviousError -Verifiable -MockWith { return $Error }
                    Mock -CommandName Assert-NoNewError -Verifiable
                    Mock -CommandName Register-ScheduledTask -Verifiable -MockWith {
                        return @{
                            Settings = @{
                                ExecutionLimit = 'PT5M'
                                Priority       = 4
                            }
                            TaskName = $functionArgs.TaskName
                            State    = 'Ready'
                        }
                    }
                    Mock -CommandName Start-ScheduledTask -Verifiable

                    Start-ExchangeScheduledTask @functionArgs
                }
            }

            $badTaskCases = @(
                @{
                    Task = $null
                },
                @{
                    Task = @{
                        State = 'Bad'
                    }
                }
            )
            Context 'When Start-ExchangeScheduledTask is called and the task fails to registery correctly' {
                It 'Should throw an exception' -TestCases $badTaskCases {
                    param
                    (
                        [System.Collections.Hashtable]
                        $Task
                    )

                    Mock -CommandName New-ScheduledTaskAction -Verifiable -MockWith { return $taskAction }
                    Mock -CommandName Get-PreviousError -Verifiable -MockWith { return $Error }
                    Mock -CommandName Assert-NoNewError -Verifiable
                    Mock -CommandName Register-ScheduledTask -Verifiable -MockWith { return $Task }
                    Mock -CommandName Start-ScheduledTask

                    { Start-ExchangeScheduledTask @functionArgs } | Should -Throw -ExpectedMessage 'Failed to register Scheduled Task'

                    Assert-MockCalled -CommandName Start-ScheduledTask -Times 0
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExtendedProtectionSPNList' -Tag 'Helper' {

            AfterEach {
                Assert-VerifiableMock
            }

            $noneInvalidCases = @(
                @{
                    Flags      = @('None', 'AllowDotlessSPN')
                    FlagsLower = @('none', 'allowdotlessspn')
                },
                @{
                    Flags      = @('None', 'NoServiceNameCheck')
                    FlagsLower = @('none', 'noservicenamecheck')
                },
                @{
                    Flags      = @('None', 'Proxy')
                    FlagsLower = @('none', 'proxy')
                },
                @{
                    Flags      = @('None', 'ProxyCoHosting')
                    FlagsLower = @('none', 'proxycohosting')
                }
            )

            Context 'When Test-ExtendedProtectionSPNList is called with the none flag, as well as other flags' {
                It 'Should return false' -TestCases $noneInvalidCases {
                    param
                    (
                        [System.String[]]
                        $Flags,

                        [System.String[]]
                        $FlagsLower
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase -Verifiable -MockWith { return $FlagsLower }

                    Test-ExtendedProtectionSPNList -SPNList @() -Flags $Flags | Should -Be $false
                }
            }

            $invalidSPNCases = @(
                @{
                    SPNList    = @('http\backslash.local')
                    Flags      = @()
                    FlagsLower = @()
                },
                @{
                    SPNList    = @('http/name')
                    Flags      = @('None')
                    FlagsLower = @('none')
                },
                @{
                    SPNList    = @('http/name.local', 'http/name')
                    Flags      = @('None')
                    FlagsLower = @('none')
                },
                @{
                    SPNList    = @('name.local')
                    Flags      = @()
                    FlagsLower = @()
                },
                @{
                    SPNList    = @()
                    Flags      = @('Proxy')
                    FlagsLower = @('proxy')
                }
            )

            Context 'When Test-ExtendedProtectionSPNList is called with straight invalid SPNs, or invalid SPNs combined with the given flags' {
                It 'Should return false' -TestCases $invalidSPNCases {
                    param
                    (
                        [System.String[]]
                        $SPNList,

                        [System.String[]]
                        $Flags,

                        [System.String[]]
                        $FlagsLower
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase -MockWith { return $FlagsLower }

                    Test-ExtendedProtectionSPNList -SPNList $SPNList -Flags $Flags | Should -Be $false
                }
            }

            $validSPNCases = @(
                @{
                    SPNList    = @('http/backslash.local')
                    Flags      = @()
                    FlagsLower = @()
                },
                @{
                    SPNList    = @('http/backslash.local')
                    Flags      = @('None')
                    FlagsLower = @('none')
                },
                @{
                    SPNList    = @('http/backslash.local')
                    Flags      = @('NoServiceNameCheck')
                    FlagsLower = @('noservicenamecheck')
                },
                @{
                    SPNList    = @('http/backslash')
                    Flags      = @('AllowDotlessSPN')
                    FlagsLower = @('allowdotlessspn')
                }
            )

            Context 'When Test-ExtendedProtectionSPNList is called with straight valid SPNs, or valid SPNs combined with the given flags' {
                It 'Should return true' -TestCases $validSPNCases {
                    param
                    (
                        [System.String[]]
                        $SPNList,

                        [System.String[]]
                        $Flags,

                        [System.String[]]
                        $FlagsLower
                    )

                    Mock -CommandName Convert-StringArrayToLowerCase -MockWith { return $FlagsLower }

                    Test-ExtendedProtectionSPNList -SPNList $SPNList -Flags $Flags | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Get-StringFromHashtable' -Tag 'Helper' {

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-StringFromHashtable is called with a hashtable containing keys and values' {
                It 'Should return a semicolon separated string of key/value pairs' {
                    $hashtable = @{
                        a = 1
                        b = 2
                        c = 3
                    }

                    Get-StringFromHashtable -Hashtable $hashtable | Should -Be 'a=1;b=2;c=3'
                }
            }
        }

        Describe 'xExchangeHelper\Get-DomainDNFromFQDN' -Tag 'Helper' {

            AfterEach {
                Assert-VerifiableMock
            }

            $testCases = @(
                @{
                    FQDN = 'domain1.local'
                    DN   = 'dc=domain1,dc=local'
                }
                @{
                    FQDN = 'sub.domain1.local'
                    DN   = 'dc=sub,dc=domain1,dc=local'
                }
                @{
                    FQDN = 'domain1'
                    DN   = 'dc=domain1'
                }
            )
            Context 'When Get-DomainDNFromFQDN is called' {
                It 'Should return the input domain in DN format' -TestCases $testCases {
                    param
                    (
                        [System.String]
                        $FQDN,

                        [System.String]
                        $DN
                    )

                    Get-DomainDNFromFQDN -Fqdn $FQDN | Should -Be $DN
                }
            }
        }

        Describe 'xExchangeHelper\Set-DSCMachineStatus' -Tag 'Helper' {
            Context 'When Set-DSCMachineStatus is called' {
                It 'Should set the desired DSCMachineStatus value' {
                    # A new value we'll attempt to set to $global:DSCMachineStatus
                    $newValue = 100

                    # Store the previous $global:DSCMachineStatus value
                    $prevDSCMachineStatus = $global:DSCMachineStatus

                    # Set and test for the new value
                    Set-DSCMachineStatus -NewDSCMachineStatus $newValue
                    $global:DSCMachineStatus | Should -Be $newValue

                    # Revert to previous $global:DSCMachineStatus value
                    $global:DSCMachineStatus = $prevDSCMachineStatus
                }
            }
        }

        Describe 'xExchangeHelper\Set-ADExtendedPermissions' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            function Add-ADPermission
            {
                param(
                    $Identity,
                    $User,
                    $ExtendedRights,
                    [Switch]
                    $Deny
                )
            }
            function Get-ADPermission
            {
                param(
                    $Identity
                )
            }

            Context 'When it is a new object' {
                It 'Should throw when the object is not found' {
                    Mock -CommandName 'Get-ADPermission' -Verifiable -ParameterFilter { $Identity -eq 'FakeADObject' }

                    { Set-ADExtendedPermissions -Identity 'FakeADobject' -NewObject } | Should -Throw "The AD Object FakeADobject was not found after 2 minutes of wait time. Please check AD replication!"
                }
                It 'Should set the allow Permissions when specified' {
                    $ExtendedRightAllowEntries = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User1Allow'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    Mock -CommandName 'Get-ADPermission' -Verifiable -ParameterFilter { $Identity -eq 'FakeADObject' } -MockWith {
                        return 'DummyOutput'
                    }
                    Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                        $Identity -eq 'FakeADObject' -and
                        $User -eq 'User1Allow' -and
                        ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                            $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                    }

                    $splat = @{
                        ExtendedRightAllowEntries = $ExtendedRightAllowEntries
                        Identity                  = 'FakeADObject'
                        NewObject                 = $true
                    }

                    Set-ADExtendedPermissions @splat
                }
                It 'Should set the deny Permissions when specified' {
                    $ExtendedRightDenyEntries = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User2Deny'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    Mock -CommandName 'Get-ADPermission' -Verifiable -ParameterFilter { $Identity -eq 'FakeADObject' } {
                        return 'DummyOutput'
                    }
                    Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                        $Identity -eq 'FakeADObject' -and
                        $User -eq 'User2Deny' -and
                        $Deny -eq $true -and
                        ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                            $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                    }

                    $splat = @{
                        ExtendedRightDenyEntries = $ExtendedRightDenyEntries
                        Identity                 = 'FakeADObject'
                        NewObject                = $true
                    }

                    Set-ADExtendedPermissions @splat
                }
            }
            Context 'When it is not a new object' {
                It 'Should set the allow Permissions when specified' {
                    $ExtendedRightAllowEntries = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User1Allow'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                        $Identity -eq 'FakeADObject' -and
                        $DomainController -eq 'FakeDC.local.com' -and
                        $User -eq 'User1Allow' -and
                        ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                            $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                    }

                    $splat = @{
                        ExtendedRightAllowEntries = $ExtendedRightAllowEntries
                        DomainController          = 'FakeDC.local.com'
                        Identity                  = 'FakeADObject'
                        NewObject                 = $true
                    }

                    Set-ADExtendedPermissions @splat
                }
                It 'Should set the deny Permissions when specified' {
                    $ExtendedRightDenyEntries = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User2Deny'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                        $Identity -eq 'FakeADObject' -and
                        $DomainController -eq 'FakeDC.local.com' -and
                        $User -eq 'User2Deny' -and
                        $Deny -eq $true -and
                        ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                            $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                    }

                    $splat = @{
                        ExtendedRightDenyEntries = $ExtendedRightDenyEntries
                        DomainController         = 'FakeDC.local.com'
                        Identity                 = 'FakeADObject'
                        NewObject                = $true
                    }

                    Set-ADExtendedPermissions @splat
                }
            }
        }
    }
}
finally
{
}

