# Change log for xExchange

## Unreleased

- Added CHANGELOG.md file.

## 1.20.0.0

- Fix issue where test of type Microsoft.Exchange.Data.Unlimited fails

## 1.19.0.0

- Added missing parameters to xExchActiveSyncVirtualDirectory
- Added missing parameters to xExchAutoDiscoverVirtualDirectory
- Added missing parameters to xExchWebServicesVirtualDirectory

## 1.18.0.0

- Fix issue #203 and add additional test for invalid ASA account format

## 1.17.0.0

- Fix issue where test for Unlimited quota fails if quota is not already set at Unlimited

## 1.16.0.0

- Add missing parameters to xExchClientAccessServer

## 1.15.0.0

- xExchDatabaseAvailabilityGroupMember: Added check to ensure Failover-Clustering role is installed before adding server to DAG.
- xExchInstall: Remove parameter '-AllowImmediateReboot $AllowImmediateReboot' when calling CheckWSManConfig.
- xExchOutlookAnywhere: Add test for ExternalClientAuthenticationMethod.
- Test: Update OAB and UMService tests to create test OAB and UMDialPlans, respectively.
- Test: Update MailboxDatabase tests to use test OAB. Update DAG to skip DAG tests and write error if cluster feature not installed.

## 1.14.0.0

- xExchDatabaseAvailabilityGroup: Added parameter AutoDagAutoRedistributeEnabled,PreferenceMoveFrequency

## 1.13.0.0

- Fix function RemoveVersionSpecificParameters
- xExchMailboxServer: Added missing parameters except these, which are marked as 'This parameter is reserved for internal Microsoft use.'

## 1.12.0.0

- xExchangeCommon : In StartScheduledTask corrected throw error check to throw last error when errorRegister has more than 0 errors instead of throwing error if errorRegister was not null, which would otherwise always be true.
- Fix PSAvoidUsingWMICmdlet issues from PSScriptAnalyzer
- Fix PSUseSingularNouns issues from PSScriptAnalyzer
- Fix PSAvoidUsingCmdletAliases issues from PSScriptAnalyzer
- Fix PSUseApprovedVerbs issues from PSScriptAnalyzer
- Fix PSAvoidUsingEmptyCatchBlock issues from PSScriptAnalyzer
- Fix PSUsePSCredentialType issues from PSScriptAnalyzer
- Fix erroneous PSDSCDscTestsPresent issues from PSScriptAnalyzer for modules that do actually have tests in the root Tests folder
- Fix array comparison issues by removing check for if array is null
- Suppress PSDSCDscExamplesPresent PSScriptAnalyzer issues for resources that do have examples
- Fix PSUseDeclaredVarsMoreThanAssignments issues from PSScriptAnalyzer
- Remove requirements for second DAG member, or second Witness server, from MSFT_xExchDatabaseAvailabilityGroup.Integration.Tests

## 1.11.0.0

- xExchActiveSyncVirtualDirectory: Fix issue where ClientCertAuth parameter set to "Allowed" instead of "Accepted"

## 1.10.0.0

- xExchAutoMountPoint: Fix malformed dash/hyphen characters
- Fix PSPossibleIncorrectComparisonWithNull issues from PowerShell Script Analyzer
- Suppress PSDSCUseVerboseMessageInDSCResource Warnings from PowerShell Script Analyzer

## 1.9.0.0

- Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.
- Added xExchMailboxTransportService resource
- xExchMailboxServer: Added WacDiscoveryEndpoint parameter

## 1.8.0.0

- Fixed PSSA issues in:
  - MSFT_xExchClientAccessServer
  - MSFT_xExchAntiMalwareScanning
  - MSFT_xExchWaitForMailboxDatabase
  - MSFT_xExchWebServicesVirtualDirectory
  - MSFT_xExchExchangeCertificate
  - MSFT_xExchWaitForDAG
  - MSFT_xExchUMService
  - MSFT_xExchUMCallRouterSettings
  - MSFT_xExchReceiveConnector
  - MSFT_xExchPowershellVirtualDirectory
  - MSFT_xExchPopSettings
  - MSFT_xExchOwaVirtualDirectory
  - MSFT_xExchOutlookAnywhere
  - MSFT_xExchOabVirtualDirectory
  - MSFT_xExchMapiVirtualDirectory
  - MSFT_xExchMailboxServer
  - MSFT_xExchImapSettings
  - MSFT_xExchExchangeServer
  - MSFT_xExchEventLogLevel
  - MSFT_xExchEcpVirtualDirectory
  - MSFT_xExchDatabaseAvailabilityGroupNetwork
  - MSFT_xExchDatabaseAvailabilityGroupMember
  - MSFT_xExchDatabaseAvailabilityGroup

## 1.7.0.0

- xExchOwaVirtualDirectory
  - Added `LogonFormat` parameter.
  - Added `DefaultDomain` parameter.
- Added FileSystem parameter to xExchDatabaseAvailabilityGroup
- Fixed PSSA issues in MSFT_xExchAutodiscoverVirtualDirectory and MSFT_xExchActiveSyncVirtualDirectory
- Updated xExchAutoMountPoint to disable Integrity Checking when formatting volumes as ReFS. This aligns with the latest version of DiskPart.ps1 from the Exchange Server Role Requirements Calculator.

## 1.6.0.0

- Added DialPlans parameter to xExchUMService

## 1.5.0.0

- Added support for Exchange 2016!
- Added Pester tests for the following resources: xExchActiveSyncVirtualDirectory, xExchAutodiscoverVirtualDirectory, xExchClientAccessServer, xExchDatabaseAvailabilityGroup, xExchDatabaseAvailabilityGroupMember, xExchEcpVirtualDirectory, xExchExchangeServer, xExchImapSettings, xExchMailboxDatabase, xExchMailboxDatabaseCopy, xExchMapiVirtualDirectory, xExchOabVirtualDirectory, xExchOutlookAnywhere, xExchOwaVirtualDirectory, xExchPopSettings, xExchPowershellVirtualDirectory, xExchUMCallRouterSettings, xExchUMService, xExchWebServicesVirtualDirectory
- Fixed minor Get-TargetResource issues in xExchAutodiscoverVirtualDirectory, xExchImapSettings, xExchPopSettings, xExchUMCallRouterSettings, and xExchWebServicesVirtualDirectory
- Added support for extended rights to resource xExchReceiveConnector (ExtendedRightAllowEntries/ExtendedRightDenyEntries)
- Fixed issue where Set-Targetresource is triggered each time consistency check runs in xExchReceiveConnector due to extended permissions on Receive Connector
- Added parameter MaximumActiveDatabases and MaximumPreferredActiveDatabases to resource xExchMailBoxServer

## 1.4.0.0

- Added following resources:
  - xExchMaintenanceMode
  - xExchMailboxServer
  - xExchTransportService
  - xExchEventLogLevel
- For all -ExchangeCertificate functions in xExchExchangeCertificate, added '-Server $env:COMPUTERNAME' switch. This will prevent the resource from configuring a certificate on an incorrect server.
- Fixed issue with reading MailboxDatabases.csv in xExchangeConfigHelper.psm1 caused by a column name changed introduced in v7.7 of the Exchange Server Role Requirements Calculator.
- Changed function GetRemoteExchangeSession so that it will throw an exception if Exchange setup is in progress. This will prevent resources from trying to execute while setup is running.
- Fixed issue where VirtualDirectory resources would incorrectly try to restart a Back End Application Pool on a CAS role only server.
- Added support for the /AddUMLanguagePack parameter in xExchInstall

## 1.3.0.0

- MSFT_xExchWaitForADPrep: Removed obsolete VerbosePreference parameter from Test-TargetResource
- Fixed encoding

## 1.2.0.0

- xExchWaitForADPrep
  - Removed `VerbosePreference` parameter of Test-TargetResource function to resolve schema mismatch error.

- Added xExchAntiMalwareScanning resource

- xExchJetstress:
  - Added fix for an issue where JetstressCmd.exe would not relaunch successfully after ESE initialization. If Jetstress doesn't restart, the resource will now require a reboot before proceeding.

- xExchOwaVirtualDirectory:
  - Added `ChangePasswordEnabled` parameter
  - Added `LogonPagePublicPrivateSelectionEnabled` parameter
  - Added `LogonPageLightSelectionEnabled` parameter

- xExchImapSettings:
  - Added `ExternalConnectionSettings` parameter
  - Added `X509CertificateName` parameter

- xExchPopSettings:
  - Added `ExternalConnectionSettings` parameter
  - Added `X509CertificateName` parameter

- Added EndToEndExample

- Fixed bug where StartScheduledTask would throw an error message and fail to set ExecutionTimeLimit and Priority when using domain credentials

## 1.1.0.0

- xExchAutoMountPoint:
  - Added parameter `EnsureExchangeVolumeMountPointIsLast`

- xExchExchangeCertificate: Added error logging for the `Enable-ExchangeCertificate` cmdlet

- xExchExchangeServer: Added pre-check for deprecated Set-ExchangeServer parameter, WorkloadManagementPolicy

- xExchJetstressCleanup: When OutputSaveLocation is specified, Stress- files will also now be saved

- xExchMailboxDatabase:
  - Added `AdServerSettingsPreferredServer` parameter
  - Added `SkipInitialDatabaseMount` parameter, which can help in an enviroments where databases need time to be able to mount successfully after creation
  - Added better error logging for `Mount-Database`
  - Databases will only be mounted at initial database creation if `MountAtStartup` is `$true` or not specified

- xExchMailboxDatabaseCopy:
  - Added `SeedingPostponed` parameter
  - Added `AdServerSettingsPreferredServer` parameter
  - Changed so that `ActivationPreference` will only be set if the number of existing copies for the database is greater than or equal to the specified ActivationPreference
  - Changed so that a seed of a new copy is only performed if `SeedingPostponed` is not specified or set to `$false`
  - Added better error logging for `Add-MailboxDatabaseCopy`
  - Added missing tests for `EdbFilePath` and `LogFolderPath`

- xExchOwaVirtualDirectory: Added missing test for `InstantMessagingServerName`

- xExchWaitForMailboxDatabase: Added `AdServerSettingsPreferredServer` parameter

- ExchangeConfigHelper.psm1: Updated `DBListFromMailboxDatabaseCopiesCsv` so that the DB copies that are returned are sorted by Activation Preference in ascending order.

## 1.0.3.11

- xExchJetstress Changes:
  - Changed default for MaxWaitMinutes from 4320 to 0
  - Added property MinAchievedIOPS
  - Changed priority of the JetstressCmd.exe Scheduled Task from the default of 7 to 4
- xExchJetstressCleanup Changes:
  - Fixed issue which caused the cleanup to not work properly when only a single database is used in JetstressConfig.xml
- xExchAutoMountPoint Changes:
  - Updated resource to choose the next available EXVOL mount point to use for databases numerically by volume number instead of alphabetically by volume number (ie. EXVOL2 would be selected after EXVOL1 instead of EXVOL11, which is alphabetically closer).

## 1.0.3.6

- Added the following resources:
  - xExchInstall
  - xExchJetstress
  - xExchJetstressCleanup
  - xExchUMCallRouterSettings
  - xExchWaitForADPrep
- xExchActiveSyncVirtualDirectory Changes:
  - Fixed an issue where if AutoCertBasedAuth was being configured, it would result in an IISReset and an app pool recycle. Now only an IISReset will occur in this scenario.
- xExchAutoMountPoint Changes:
  - Added CreateSubfolders parameter
  - Moved many DiskPart functions into helper file Misc\xExchangeDiskPart.ps1
  - Updated so that ExchangeVolume mount points will be listed AFTER ExchangeDatabase mount points on the same disk
- xExchExchangeCertificate Changes:
  - Changed behavior so that if UM or UMCallRouter services are being enabled, the UM or UMCallRouter services will be stopped before the enablement, then restarted after the enablement.
- xExchMailboxDatabase Changes:
  - Fixed an issue where the OfflineAddressBook property would not be tested properly depending on if a slash was specified or not at the beginning of the OAB name. Now the slash doesn't matter.
- xExchOutlookAnywhere Changes:
  - Changed the test for ExternalClientsRequireSsl to only fire if ExternalHostname is also specified.
- xExchUMService Changes:
  - Fixed issue that was preventing tests from evaluating properly.
- Example Updates:
  - Added example folder InstallExchange
  - Added example folder JetstressAutomation
  - Added example folder WaitForADPrep
  - Renamed EndToEndExample to PostInstallationConfiguration
  - Updated Start-DscConfiguration commands in ConfigureDatabasesFromCalculator, ConfigureDatabasesManual, ConfigureVirtualDirectories, CreateAndConfigureDAG, and EndToEndExample, as they were missing a required space between parameters

## 1.0.1.0

- Updated all Examples with minor comment changes, and re-wrote the examples ConfigureAutoMountPoint-FromCalculator and ConfigureAutoMountPoints-Manual.
- Updated Exchange Server Role Requirement Calculator examples from version 6.3 to 6.6

## 1.0.0.0

- Initial release with the following resources:
  - xExchActiveSyncVirtualDirectory
  - xExchAutodiscoverVirtualDirectory
  - xExchAutoMountPoint
  - xExchClientAccessServer
  - xExchDatabaseAvailabilityGroup
  - xExchDatabaseAvailabilityGroupMember
  - xExchDatabaseAvailabilityGroupNetwork
  - xExchEcpVirtualDirectory
  - xExchExchangeCertificate
  - xExchExchangeServer
  - xExchImapSettings
  - xExchMailboxDatabase
  - xExchMailboxDatabaseCopy
  - xExchMapiVirtualDirectory
  - xExchOabVirtualDirectory
  - xExchOutlookAnywhere
  - xExchOwaVirtualDirectory
  - xExchPopSettings
  - xExchPowerShellVirtualDirectory
  - xExchReceiveConnector
  - xExchUMService
  - xExchWaitForDAG
  - xExchWaitForMailboxDatabase
  - xExchWebServicesVirtualDirectory