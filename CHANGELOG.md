# Change log for xExchange

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For older change log history see the [historic changelog](HISTORIC_CHANGELOG.md).

## [Unreleased]

### Changed

- xExchange
  - Fixing the Get-TargetResource function in xExchAcceptedDomain.
  - Setting Pester version to 4.10.1, since changes in the Unit Tests are reuquired
  in order for Pester 5 to work properly.
## [1.32.0] - 2020-05-13

### Changed

- xExchange
  - Update CI pipeline files.
  - Fixing xExchSendConnector ExtendedRight functionality by moving the test function
  to the helper module and setting explicit Deny permissions, instead of removing
  the marked as 'Deny' entries.
  - A remote implicing module with all Exchange cmdlets will be created under
  $env:Temp and reused every time DSC check runs, instead of creating a new
  module every time.
  - Added AD Permissions parameter for xExchReceiveConnector.
  - xExchAddressList: Removing the scriptblock creation for RecipientFilter
  property in Get-TargetResource.
  - Adding missing TlsAuthLevel to xExchSendConnector Get-TargetResource function. 
  - Small bug fix in xExchangeHelper module.

## [1.31.0] - 2020-01-27

### Added

- Added xExchAddressList ressource
- Added xExchSendConnector resource

### Changed

- Added additional parameters to the MSFT_xExchImapSettings resource
- Added additional parameters to the xExchMailboxTransportService resource
- Fixed unit test it statement for MSFT_xExchAutodiscoverVirtualDirectory\Test-TargetResource
- Migrated to Azure DevOps Release model

## [1.30.0.0] - 2019-10-30

### Added

- Added xExchAcceptedDomain resource
- Added xExchRemoteDomain resource

### Changed

- Resolved custom Script Analyzer rules that was added to the test framework.
- Resolved hashtable styling issues
