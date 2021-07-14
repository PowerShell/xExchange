<#
    .SYNOPSIS
        Automated integration test for the xExchangeHelper helper module.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1'))) -Force

<#
    .SYNOPSIS
        Remove any existing Remote PowerShell sessions created by xExchange and
        verify they are gone.
#>
function Remove-ExistingPSSession
{
    [CmdletBinding()]
    param ()

    Context 'Remove existing Remote PowerShell Session to Exchange' {
        # Remove-RemoteExchangeModule
        Remove-RemoteExchangeSession

        $Session = $null
        $Session = Get-ExistingRemoteExchangeSession

        It 'Get-ExistingRemoteExchangeSession should return Null' {
            $Session | Should BeNullOrEmpty
        }
    }
}

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    Describe 'xExchangeHelper\Get-RemoteExchangeSession' -Tag 'Helper' {
        # Remove any existing Remote PS Sessions to Exchange before getting started
        Remove-ExistingPSSession

        # Verify we can setup a new Remote PS Session to Exchange
        Context 'When establishing a new Remote PowerShell Session to Exchange' {
            Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-ExchangeServer'

            $Session = $null
            $Session = Get-ExistingRemoteExchangeSession

            It 'The Session Should Not Be Null' {
                ($null -ne $Session) | Should Be $true
            }
        }

        # Remove sessions again before continuing
        # Remove-ExistingPSSession
        Remove-RemoteExchangeSession

        # Simulate that setup is running (using notepad.exe), and try to establish a new session. This should fail
        Context 'When requesting a new Remote PowerShell Session to Exchange and Exchange setup is running' {
            Start-Process Notepad.exe

            It 'Get-RemoteExchangeSession Should Throw Exception When Setup Process Is Specified and Detected' {
                { Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-ExchangeServer' -SetupProcessName 'notepad' } | Should -Throw
            }

            It 'Get-ExistingRemoteExchangeSession should return Null' {
                $Session = $null
                $Session = Get-ExistingRemoteExchangeSession

                ($null -eq $Session) | Should Be $true
            }
        }
    }

    Describe 'xExchangeHelper\Compare-UnlimitedToString' -Tag 'Helper' {
        <#
            Test for issue (https://github.com/PowerShell/xExchange/issues/211)
            Calling Compare-UnlimitedToString when the Unlimited is of type [Microsoft.Exchange.Data.Unlimited`1[System.Int32]]
            and the string value contains a number throws an exception.
        #>

        [Microsoft.Exchange.Data.Unlimited`1[System.Int32]] $unlimitedInt32 = 1000

        Context 'When Compare-UnlimitedToString is called using an Int32 Unlimited and a String Containing a Number' {
            It 'Should not throw an exception' {
                { Compare-UnlimitedToString -Unlimited $unlimitedInt32 -String '1000' } | Should -Not -Throw
            }
        }

        Context 'When Compare-UnlimitedToString is called using an Int32 Unlimited and a String Containing similar numbers' {
            It 'Should return true' {
                Compare-UnlimitedToString -Unlimited $unlimitedInt32 -String '1000' | Should -Be $true
            }
        }

        Context 'When Compare-UnlimitedToString is called using an Int32 Unlimited and a String Containing different numbers' {
            It 'Should return false' {
                Compare-UnlimitedToString -Unlimited $unlimitedInt32 -String '100' | Should -Be $false
            }
        }
    }

    Describe 'xExchangeHelper\Compare-ADObjectIdToSmtpAddressString' -Tag 'Helper' {
        # Get test PS Session and setup test variables
        Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-AcceptedDomain', '*-Mailbox', '*-MailUser', '*-MailContact', 'Get-Recipient', 'Get-MailboxDatabase'

        $testMailbox = Get-DSCTestMailbox -Verbose
        $testMailboxADObjectID = [Microsoft.Exchange.Data.Directory.ADObjectId]::ParseDnOrGuid($testMailbox.DistinguishedName)

        if ($null -eq $testMailboxADObjectID)
        {
            throw 'Failed to retrieve ADObjectID for test mailbox'
        }

        $testMailboxSecondaryAddress = ($testMailbox.EmailAddresses | Where-Object { $_.IsPrimaryAddress -eq $false -and $_.Prefix -like 'SMTP' } | Select-Object -First 1).AddressString

        if ([String]::IsNullOrEmpty($testMailboxSecondaryAddress))
        {
            throw 'Failed to find secondary SMTP address on test mailbox'
        }

        $testMailUser = Get-DSCTestMailUser -Verbose
        $testMailUserADObjectID = [Microsoft.Exchange.Data.Directory.ADObjectId]::ParseDnOrGuid($testMailUser.DistinguishedName)

        if ($null -eq $testMailUserADObjectID)
        {
            throw 'Failed to retrieve ADObjectID for test mail user'
        }

        $testMailContact = Get-DSCTestMailContact -Verbose
        $testMailContactADObjectID = [Microsoft.Exchange.Data.Directory.ADObjectId]::ParseDnOrGuid($testMailContact.DistinguishedName)

        if ($null -eq $testMailContactADObjectID)
        {
            throw 'Failed to retrieve ADObjectID for test mail contact'
        }

        # Start testing
        Context 'When comparing the ADObjectID of a mailbox to its PrimarySmtpAddress' {
            It 'Should return $true' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailboxADObjectID -AddressString $testMailbox.PrimarySmtpAddress.Address

                $compareResults | Should -Be $true
            }
        }

        Context 'When comparing the ADObjectID of a mailbox to one of its secondary SMTP addresses' {
            It 'Should return $true' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailboxADObjectID -AddressString $testMailboxSecondaryAddress

                $compareResults | Should -Be $true
            }
        }

        Context 'When comparing the ADObjectID of a mailbox to an empty string' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailboxADObjectID -AddressString ''

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing the ADObjectID of a mailbox to a null string' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailboxADObjectID -AddressString $null

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing a null ADObjectID to a valid SMTP address' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString $testMailbox.PrimarySmtpAddress.Address

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing the ADObjectID of a mail user to its ExternalEmailAddress' {
            It 'Should return $true' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailUserADObjectID -AddressString $testMailUser.ExternalEmailAddress.AddressString

                $compareResults | Should -Be $true
            }
        }

        Context 'When comparing the ADObjectID of a mail user to an empty string' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailUserADObjectID -AddressString ''

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing the ADObjectID of a mail user to a null string' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailUserADObjectID -AddressString $null

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing the ADObjectID of a mail contact to its ExternalEmailAddress' {
            It 'Should return $true' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailContactADObjectID -AddressString $testMailContact.ExternalEmailAddress.AddressString

                $compareResults | Should -Be $true
            }
        }

        Context 'When comparing the ADObjectID of a mail contact to an empty string' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailContactADObjectID -AddressString ''

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing the ADObjectID of a mail contact to a null string' {
            It 'Should return $false' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testMailContactADObjectID -AddressString $null

                $compareResults | Should -Be $false
            }
        }

        Context 'When comparing a null ADObjectID to an empty string' {
            It 'Should return $true' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString ''

                $compareResults | Should -Be $true
            }
        }

        Context 'When comparing a null ADObjectID to a null string' {
            It 'Should return $true' {
                $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString $null

                $compareResults | Should -Be $true
            }
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}

