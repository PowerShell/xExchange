# Change log for xExchange

## Unreleased
- Remove check for Windows Failover-Clustering role before adding a new DAG member

- Added xExchAddressList ressource
- Added xExchSendConnector resource
- Added additional parameters to the MSFT_xExchImapSettings resource
- Added additional parameters to the xExchMailboxTransportService resource
- Fixed unit test it statement for MSFT_xExchAutodiscoverVirtualDirectory\Test-TargetResource

## 1.30.0.0

- Resolved custom Script Analyzer rules that was added to the test framework.
- Added xExchAcceptedDomain resource
- Resolved hashtable styling issues
- Added xExchRemoteDomain resource

## 1.29.0.0

- Enable Script Analyzer default rules
- Add the AutoDagBitlockerEnabled parameter to DSC resource MSFT_xExchDatabaseAvailabilityGroup
- Fixed keywords in upper case

## 1.28.0.0

- Added MSFT_xExchFrontendTransportService resource, based on
  MSFT_xExchTransportService resource.
  [Issue #283](https://github.com/PowerShell/xExchange/issues/283)
- Added unit and integration tests to the MSFT_xExchFrontendTransportService resource.
- Added comment based help to the MSFT_xExchFrontendTransportService resource.
- Minor style fix in MSFT_xExchEcpVirtualDirectory to ensure new PowerShell
  Script Analyzer custom rules pass.

## 1.27.0.0

- Added additional parameters to the MSFT_xExchTransportService resource
- Added additional parameters to the MSFT_xExchEcpVirtualDirectory resource
- Added additional unit tests to the MSFT_xExchAutodiscoverVirutalDirectory resource
- Added additional parameters to the MSFT_xExchExchangeCertificate resource
- MSFT_xExchMailboxDatabase: Fixes issue with DataMoveReplicationConstraint
  parameter (#401)
- Added additional parameters and comment based help to the
  MSFT_xExchMailboxDatabase resource
- Move code that sets $global:DSCMachineStatus into a dedicated helper
  function.
  [Issue #407](https://github.com/PowerShell/xExchange/issues/407)
- Add missing parameters for xExchMailboxDatabaseCopy, adds comment based help,
  and adds remaining Unit tests.

## 1.26.0.0

- Add support for Exchange Server 2019
- Added additional parameters to the MSFT_xExchUMService resource
- Rename improperly named functions, and add comment based help in
  MSFT_xExchClientAccessServer, MSFT_xExchDatabaseAvailabilityGroupNetwork,
  MSFT_xExchEcpVirtualDirectory, MSFT_xExchExchangeCertificate,
  MSFT_xExchImapSettings.
- Added additional parameters to the MSFT_xExchUMCallRouterSettings resource
- Rename improper function names in MSFT_xExchDatabaseAvailabilityGroup,
  MSFT_xExchJetstress, MSFT_xExchJetstressCleanup, MSFT_xExchMailboxDatabase,
  MSFT_xExchMailboxDatabaseCopy, MSFT_xExchMailboxServer,
  MSFT_xExchMaintenanceMode, MSFT_xExchMapiVirtualDirectory,
  MSFT_xExchOabVirtualDirectory, MSFT_xExchOutlookAnywhere,
  MSFT_xExchOwaVirtualDirectory, MSFT_xExchPopSettings,
  MSFT_xExchPowershellVirtualDirectory, MSFT_xExchReceiveConnector,
  MSFT_xExchWaitForMailboxDatabase, and MSFT_xExchWebServicesVirtualDirectory.
- Add remaining unit and integration tests for MSFT_xExchExchangeServer.

## 1.25.0.0

- Opt-in for the common test flagged Script Analyzer rules
  ([issue #234](https://github.com/PowerShell/xExchange/issues/234)).
- Opt-in for the common test testing for relative path length.
- Removed the property `PSDscAllowPlainTextPassword` from all examples
  so the examples are secure by default. The property
  `PSDscAllowPlainTextPassword` was previously needed to (test) compile
  the examples in the CI pipeline, but now the CI pipeline is using a
  certificate to compile the examples.
- Opt-in for the common test that validates the markdown links.
- Fix typo of the word 'Certificate' in several example files.
- Add spaces between array members.
- Add initial set of Unit Tests (mostly Get-TargetResource tests) for all
  remaining resource files.
- Add WaitForComputerObject parameter to xExchWaitForDAG
- Add spaces between comment hashtags and comments.
- Add space between variable types and variables.
- Fixes issue where xExchMailboxDatabase fails to test for a Journal Recipient
  because the module did not load the Get-Recipient cmdlet (#335).
- Fixes broken Integration tests in
  MSFT_xExchMaintenanceMode.Integration.Tests.ps1 (#336).
- Fix issue where Get-ReceiveConnector against an Absent connector causes an
  error to be logged in the MSExchange Management log.
- Rename poorly named functions in xExchangeDiskPart.psm1 and
  MSFT_xExchAutoMountPoint.psm1, and add comment based help.

## 1.24.0.0

- xExchangeHelper.psm1: Renamed common functions to use proper Verb-Noun
  format. Also addresses many common style issues in functions in the file, as
  well as in calls to these functions from other files.
- MSFT_xExchTransportService: Removed functions that were duplicates of helper
  functions in xExchangeHelper.psm1.
- Fixes an issue where only objects of type Mailbox can be specified as a
  Journal Recipient. Now MailUser and MailContact types can be used as well.
- Update appveyor.yml to use the default template.
- Added default template files .codecov.yml, .gitattributes, and .gitignore, and
  .vscode folder.
- Add Unit Tests for xExchAntiMalwareScanning
- Add remaining Unit Tests for xExchInstall, and for most common setup
  functions
- Added ActionForUnknownFileAndMIMETypes,WSSAccessOnPublicComputersEnabled,
  WSSAccessOnPrivateComputersEnabled,UNCAccessOnPublicComputersEnabled
  UNCAccessOnPrivateComputersEnabled and GzipLevel to xExchOwaVirtualDirectory.
- Added GzipLevel and AdminEnabled to xExchEcpVirtualDirectory.
- Added OAuthAuthentication to xExchOabVirtualDirectory.
- Updated readme with the new parameters and removed a bad parameter from
  xExchOwaVirtualDirectory that did not actually exist.
- Updated .gitattributes to allow test .pfx files to be saved as binary
- Added Cumulative Update / Exchange update support to xExchInstall resource.
- Add remaining Unit Tests for all xExchangeHelper functions that don't
  require the loading of Exchange DLL's.
- Renamed and moved file Examples/HelperScripts/ExchangeConfigHelper.psm1 to
  Modules/xExchangeCalculatorHelper.psm1. Renamed functions within the module
  to conform to proper function naming standards. Added remaining Unit tests
  for module.

## 1.23.0.0

- Fixes issue with xExchMaintenanceMode on Exchange 2016 where the cluster
  does not get paused when going into maintenance mode. Also fixes issue
  where services fail to stop, start, pause, or resume.
- Explicitly cast member types in Get-DscConfiguration return hashtables to
  align with the types defined in the resource schemas. Fixes an issue where
  Get-DscConfiguration fails to return a value.
- xExchClientAccessServer: Fixes issue where AlternateServiceAccountConfiguration
  or RemoveAlternateServiceAccountCredentials parameters can't be used at the
  same time as other optional parameters.
- xExchInstall: Fixes issue where Test-TargetResource returns true if setup is
  running. Fixes issue where setup is not detected as having been successfully
  completed even if setup was successful. Adds initial set of unit tests for
  xExchInstall and related functions.
- Remove VerbosePreference from function parameters and update all calls to
  changed functions.
- Fixes multiple PSScriptAnalyzer issues. Specifically, fixes all instances of
  PSAvoidTrailingWhitespace, PSAvoidGlobalVars,
  PSAvoidUsingConvertToSecureStringWithPlainText, PSUseSingularNouns, and
  fixes many instances of PSUseDeclaredVarsMoreThanAssignments.
- Add support for Exchange Server 2019 - Preview

## 1.22.0.0

- Fixed issue in xExchInstall where winrm config command fails to execute
- Fixed issue in xExchInstall where a failed Exchange setup run is not
  reported, and subsequent DSC resources are allowed to run
- Fixed issue in xExchAutoMountPoint where Test-TargetResource fails
  after mount points have been successfully configured.
- Fixed issue in xExchAutoMountPoint where Set-TargetResource fails
  if EnsureExchangeVolumeMountPointIsLast parameter is specified.
- Updated xExchAutoMountPoint, xExchJetstressCleanup, and related DiskPart
  functions to not use global variables.
- Fixes broken tests in:
  MSFT_xExchDatabaseAvailabilityGroup.Integration.Tests.ps1,
  MSFT_xExchExchangeCertificate.Integration.Tests.ps1,
  MSFT_xExchOutlookAnywhere.Integration.Tests.ps1,
  MSFT_xExchPopSettings.Integration.Tests.ps1,
  xExchangeConfigHelper.Unit.Tests.ps1
- Update most Test-TargetResource functions to output all invalid settings,
  instead of just the first detected invalid setting

## 1.21.0.0

- Added CHANGELOG.md file
- Added .markdownlint.json file
- Updated README.md and CHANGELOG.md files to respect MD009, MD0013 and MD032 rules
- Added .MetaTestOptIn.json file
- Updated appveyor.yml file
- Added .codecov.yml file
- Renamed Test folder to Tests
- Updated README.md: Add codecov badges
- Fixed PSSA required rules in:
  - xExchClientAccessServer.psm1
  - xExchInstall.psm1
  - xExchMaintenanceMode.psm1
  - TransportMaintenance.psm1
  - xExchTransportService.psm1
- Fixed Validate Example files in:
  - ConfigureAutoMountPoints-FromCalculator.ps1
  - ConfigureAutoMountPoints-Manual.ps1
  - ConfigureDatabases-FromCalculator.ps1
  - InternetFacingSite.ps1
  - RegionalNamespaces.ps1
  - SingleNamespace.ps1
  - ConfigureVirtualDirectories.ps1
  - CreateAndConfigureDAG.ps1
  - EndToEndExample 1 to 10 files
  - JetstressAutomation
  - MaintenanceMode
  - PostInstallationConfiguration.ps1
  - InstallExchange.ps1
  - QuickStartTemplate.ps1
  - WaitForADPrep.ps1
- Remove default value for Switch Parameter in
  TransportMaintenance.psm1 for functions:
  - Clear-DiscardEvent
  - LogIfRemain
  - Wait-EmptyEntriesCompletion
  - Update-EntriesTracker
  - Remove-CompletedEntriesFromHashtable
- Fixed PSSA custom rules in:
  - xExchActiveSyncVirtualDirectory.psm1
  - xExchAntiMalwareScanning.psm1
  - xExchAutodiscoverVirtualDirectory.psm1
  - xExchAutoMountPoint.psm1
  - xExchClientAccessServer.psm1
  - xExchDatabaseAvailabilityGroup.psm1
  - xExchDatabaseAvailabilityGroupMember.psm1
  - xExchDatabaseAvailabilityGroupNetwork.psm1
  - xExchEcpVirtualDirectory.psm1
  - xExchEventLogLevel.psm1
  - xExchExchangeCertificate.psm1
  - xExchExchangeServer.psm1
  - xExchImapSettings.psm1
  - xExchInstall.psm1
  - xExchJetstress.psm1
  - xExchJetstressCleanup.psm1
  - xExchMailboxDatabase.psm1
  - xExchMailboxDatabaseCopy.psm1
  - xExchMailboxServer.psm1
  - xExchMailboxTransportService.psm1
  - xExchMaintenanceMode.psm1
  - xExchMapiVirtualDirectory.psm1
  - xExchOabVirtualDirectory.psm1
  - xExchOutlookAnywhere.psm1
  - xExchOwaVirtualDirectory.psm1
  - xExchPopSettings.psm1
  - xExchPowerShellVirtualDirectory.psm1
  - xExchReceiveConnector.psm1
  - xExchUMCallRouterSettings.psm1
  - xExchUMService.psm1
  - xExchWaitForADPrep.psm1
  - xExchWaitForDAG.psm1
  - xExchWaitForMailboxDatabase.psm1
  - xExchWebServicesVirtualDirectory.psm1
- Updated xExchange.psd1
- Added issue template file (ISSUE\_TEMPLATE.md) for 'New Issue' and pull request
  template file (PULL\_REQUEST\_TEMPLATE.md) for 'New Pull Request'.
- Fix issue Diagnostics.CodeAnalysis.SuppressMessageAttribute best practices
- Renamed xExchangeCommon.psm1 to xExchangeHelper.psm1
- Renamed the folder MISC (that contains the helper) to Modules
- Added xExchangeHelper.psm1 in xExchange.psd1 (section NestedModules)
- Removed all lines with Import-Module xExchangeCommon.psm1
- Updated .MetaTestOptIn.json file with Custom Script Analyzer Rules
- Added Integration, TestHelpers and Unit folder
- Moved Data folder in Tests
- Moved Integration tests to Integration folder
- Moved Unit test to Unit folder
- Renamed xEchange.Tests.Common.psm1 to xExchangeTestHelper.psm1
- Renamed xEchangeCommon.Unit.Tests.ps1 to xExchangeCommon.Tests.ps1
- Renamed function PrepTestDAG to Initialize-TestForDAG
- Moved function Initialize-TestForDAG to xExchangeTestHelper.psm1
- Fix error-level PS Script Analyzer rules for TransportMaintenance.psm1

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

- xExchDatabaseAvailabilityGroupMember: Added check to ensure Failover-Clustering
  role is installed before adding server to DAG.
- xExchInstall: Remove parameter '-AllowImmediateReboot $AllowImmediateReboot'
  when calling CheckWSManConfig.
- xExchOutlookAnywhere: Add test for ExternalClientAuthenticationMethod.
- Test: Update OAB and UMService tests to create test OAB and UMDialPlans, respectively.
- Test: Update MailboxDatabase tests to use test OAB. Update DAG to skip DAG tests
  and write error if cluster feature not installed.

## 1.14.0.0

- xExchDatabaseAvailabilityGroup:
  Added parameter AutoDagAutoRedistributeEnabled, PreferenceMoveFrequency

## 1.13.0.0

- Fix function RemoveVersionSpecificParameters
- xExchMailboxServer: Added missing parameters except these, which are marked as
  'This parameter is reserved for internal Microsoft use.'

## 1.12.0.0

- xExchangeCommon : In Start-ExchangeScheduledTask corrected throw error check
  to throw
  last error when errorRegister has more than 0 errors instead of throwing error
  if errorRegister was not null, which would otherwise always be true.
- Fix PSAvoidUsingWMICmdlet issues from PSScriptAnalyzer
- Fix PSUseSingularNouns issues from PSScriptAnalyzer
- Fix PSAvoidUsingCmdletAliases issues from PSScriptAnalyzer
- Fix PSUseApprovedVerbs issues from PSScriptAnalyzer
- Fix PSAvoidUsingEmptyCatchBlock issues from PSScriptAnalyzer
- Fix PSUsePSCredentialType issues from PSScriptAnalyzer
- Fix erroneous PSDSCDscTestsPresent issues from PSScriptAnalyzer for modules
  that do actually have tests in the root Tests folder
- Fix array comparison issues by removing check for if array is null
- Suppress PSDSCDscExamplesPresent PSScriptAnalyzer issues for resources
  that do have examples
- Fix PSUseDeclaredVarsMoreThanAssignments issues from PSScriptAnalyzer
- Remove requirements for second DAG member, or second Witness server,
  from MSFT_xExchDatabaseAvailabilityGroup.Integration.Tests

## 1.11.0.0

- xExchActiveSyncVirtualDirectory: Fix issue where ClientCertAuth parameter set
  to "Allowed" instead of "Accepted"

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
- Updated xExchAutoMountPoint to disable Integrity Checking when formatting volumes
  as ReFS. This aligns with the latest version of DiskPart.ps1 from the Exchange
  Server Role Requirements Calculator.

## 1.6.0.0

- Added DialPlans parameter to xExchUMService

## 1.5.0.0

- Added support for Exchange 2016!
- Added Pester tests for the following resources:
  - xExchActiveSyncVirtualDirectory,
  - xExchAutodiscoverVirtualDirectory,
  - xExchClientAccessServer,
  - xExchDatabaseAvailabilityGroup,
  - xExchDatabaseAvailabilityGroupMember,
  - xExchEcpVirtualDirectory,
  - xExchExchangeServer,
  - xExchImapSettings,
  - xExchMailboxDatabase,
  - xExchMailboxDatabaseCopy,
  - xExchMapiVirtualDirectory,
  - xExchOabVirtualDirectory,
  - xExchOutlookAnywhere,
  - xExchOwaVirtualDirectory,
  - xExchPopSettings,
  - xExchPowershellVirtualDirectory,
  - xExchUMCallRouterSettings,
  - xExchUMService,
  - xExchWebServicesVirtualDirectory
- Fixed minor Get-TargetResource issues in xExchAutodiscoverVirtualDirectory,
  xExchImapSettings, xExchPopSettings, xExchUMCallRouterSettings, and xExchWebServicesVirtualDirectory
- Added support for extended rights to resource xExchReceiveConnector (ExtendedRightAllowEntries/ExtendedRightDenyEntries)
- Fixed issue where Set-Targetresource is triggered each time consistency check
  runs in xExchReceiveConnector due to extended permissions on Receive Connector
- Added parameter MaximumActiveDatabases and MaximumPreferredActiveDatabases to
  resource xExchMailBoxServer

## 1.4.0.0

- Added following resources:
  - xExchMaintenanceMode
  - xExchMailboxServer
  - xExchTransportService
  - xExchEventLogLevel
- For all -ExchangeCertificate functions in xExchExchangeCertificate, added
  '-Server $env:COMPUTERNAME' switch. This will prevent the resource from
  configuring a certificate on an incorrect server.
- Fixed issue with reading MailboxDatabases.csv in xExchangeConfigHelper.psm1
  caused by a column name changed introduced in v7.7 of the Exchange Server Role
  Requirements Calculator.
- Changed function Get-RemoteExchangeSession so that it will throw an exception
  if Exchange setup is in progress. This will prevent resources from trying to
  execute while setup is running.
- Fixed issue where VirtualDirectory resources would incorrectly try to restart
  a Back End Application Pool on a CAS role only server.
- Added support for the /AddUMLanguagePack parameter in xExchInstall

## 1.3.0.0

- MSFT_xExchWaitForADPrep: Removed obsolete VerbosePreference parameter from Test-TargetResource
- Fixed encoding

## 1.2.0.0

- xExchWaitForADPrep
  - Removed `VerbosePreference` parameter of Test-TargetResource function to
    resolve schema mismatch error.
- Added xExchAntiMalwareScanning resource
- xExchJetstress:
  - Added fix for an issue where JetstressCmd.exe would not relaunch successfully
    after ESE initialization. If Jetstress doesn't restart, the resource will
    now require a reboot before proceeding.
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
- Fixed bug where Start-ExchangeScheduledTask would throw an error message and
  fail to
  set ExecutionTimeLimit and Priority when using domain credentials

## 1.1.0.0

- xExchAutoMountPoint:
  Added parameter `EnsureExchangeVolumeMountPointIsLast`
- xExchExchangeCertificate:
  Added error logging for the `Enable-ExchangeCertificate` cmdlet
- xExchExchangeServer:
  Added pre-check for deprecated Set-ExchangeServer parameter, WorkloadManagementPolicy
- xExchJetstressCleanup:
  When OutputSaveLocation is specified, Stress- files will also now be saved

- xExchMailboxDatabase:
  - Added `AdServerSettingsPreferredServer` parameter
  - Added `SkipInitialDatabaseMount` parameter, which can help in an enviroments
    where databases need time to be able to mount successfully after creation
  - Added better error logging for `Mount-Database`
  - Databases will only be mounted at initial database creation
    if `MountAtStartup` is `$true` or not specified

- xExchMailboxDatabaseCopy:
  - Added `SeedingPostponed` parameter
  - Added `AdServerSettingsPreferredServer` parameter
  - Changed so that `ActivationPreference` will only be set if the number of
    existing copies for the database is greater than or equal to the specified ActivationPreference
  - Changed so that a seed of a new copy is only performed if `SeedingPostponed`
    is not specified or set to `$false`
  - Added better error logging for `Add-MailboxDatabaseCopy`
  - Added missing tests for `EdbFilePath` and `LogFolderPath`

- xExchOwaVirtualDirectory: Added missing test for `InstantMessagingServerName`

- xExchWaitForMailboxDatabase: Added `AdServerSettingsPreferredServer` parameter

- ExchangeConfigHelper.psm1: Updated `DBListFromMailboxDatabaseCopiesCsv` so
  that the DB copies that are returned are sorted by Activation Preference
  in ascending order.

## 1.0.3.11

- xExchJetstress Changes:
  - Changed default for MaxWaitMinutes from 4320 to 0
  - Added property MinAchievedIOPS
  - Changed priority of the JetstressCmd.exe Scheduled Task from
    the default of 7 to 4
- xExchJetstressCleanup Changes:
  - Fixed issue which caused the cleanup to not work properly when only
    a single database is used in JetstressConfig.xml
- xExchAutoMountPoint Changes:
  - Updated resource to choose the next available EXVOL mount point to use for
    databases numerically by volume number instead of alphabetically by volume
    number (ie. EXVOL2 would be selected after EXVOL1 instead of EXVOL11,
    which is alphabetically closer).

## 1.0.3.6

- Added the following resources:
  - xExchInstall
  - xExchJetstress
  - xExchJetstressCleanup
  - xExchUMCallRouterSettings
  - xExchWaitForADPrep
- xExchActiveSyncVirtualDirectory Changes:
  - Fixed an issue where if AutoCertBasedAuth was being configured,
    it would result in an IISReset and an app pool recycle.
    Now only an IISReset will occur in this scenario.
- xExchAutoMountPoint Changes:
  - Added CreateSubfolders parameter
  - Moved many DiskPart functions into helper file Misc\xExchangeDiskPart.ps1
  - Updated so that ExchangeVolume mount points will be listed AFTER
    ExchangeDatabase mount points on the same disk
- xExchExchangeCertificate Changes:
  - Changed behavior so that if UM or UMCallRouter services are being enabled,
    the UM or UMCallRouter services will be stopped before the enablement,
    then restarted after the enablement.
- xExchMailboxDatabase Changes:
  - Fixed an issue where the OfflineAddressBook property would not be
    tested properly depending on if a slash was specified or not at
    the beginning of the OAB name. Now the slash doesn't matter.
- xExchOutlookAnywhere Changes:
  - Changed the test for ExternalClientsRequireSsl to only fire
    if ExternalHostname is also specified.
- xExchUMService Changes:
  - Fixed issue that was preventing tests from evaluating properly.
- Example Updates:
  - Added example folder InstallExchange
  - Added example folder JetstressAutomation
  - Added example folder WaitForADPrep
  - Renamed EndToEndExample to PostInstallationConfiguration
  - Updated Start-DscConfiguration commands in ConfigureDatabasesFromCalculator,
    ConfigureDatabasesManual, ConfigureVirtualDirectories, CreateAndConfigureDAG,
    and EndToEndExample, as they were missing a required space between parameters

## 1.0.1.0

- Updated all Examples with minor comment changes, and re-wrote the examples
  ConfigureAutoMountPoint-FromCalculator and ConfigureAutoMountPoints-Manual.
- Updated Exchange Server Role Requirement Calculator examples
  from version 6.3 to 6.6

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
