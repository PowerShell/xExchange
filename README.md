# xExchange

[![Build Status](https://dev.azure.com/dsccommunity/xExchange/_apis/build/status/dsccommunity.xExchange?branchName=master)](https://dev.azure.com/dsccommunity/xExchange/_build/latest?definitionId=15&branchName=master)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/xExchange/15/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/xExchange/15/master)](https://dsccommunity.visualstudio.com/xExchange/_test/analytics?definitionId=15&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/xExchange?label=xExchange%20Preview)](https://www.powershellgallery.com/packages/xExchange/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/xExchange?label=xExchange)](https://www.powershellgallery.com/packages/xExchange/)

The **xExchange** module contains many DSC resources for configuring and
managing Exchange 2013, 2016, and 2019 servers including individual
server properties, databases, mount points, and Database Availability Groups.

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional
questions or comments.

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Installation

To manually install the module,
download the source code and unzip the contents
of the '\Modules\xExchange' directory to the
'\$env:ProgramFiles\WindowsPowerShell\Modules' folder.

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

```powershell
Find-Module -Name xExchange -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the SQL Server
DSC resources available:

```powershell
Get-DscResource -Module xExchange
```

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 4.0,
which ships with Windows Server 2012 and Windows Server 2012 R2, but can also
be installed on Windows 2008 R2 (the minimum supported OS version for Exchange
Server 2013).

Note that while the xExchange module may work with newer releases of
PowerShell, the Microsoft Exchange Product Group does not support running
Microsoft Exchange Server with versions of PowerShell newer than the one that
shipped with the Windows Server version that Exchange is installed on. See the
**Windows PowerShell** section of the [Exchange Server Supportability Matrix](<https://technet.microsoft.com/en-us/library/ff728623(v=exchg.160).aspx>)
for more information.

## Examples

You can review the [Examples](/source/Examples) directory in the xExchange module
for some general use scenarios for all of the resources that are in the module.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

- **xExchAcceptedDomain** is used to add accepted domains
- **xExchActiveSyncVirtualDirectory**
- **xExchAddressList** is used to add an addess list
- **xExchAntiMalwareScanning** is used to enable or disable Exchange
  Anti-malware scanning
- **xExchAutodiscoverVirtualDirectory**
- **xExchAutoMountPoint**
- **xExchClientAccessServer**
- **xExchDatabaseAvailabilityGroup** configures a Database Availability Group
  using New/Set-DatabaseAvailibilityGroup.
- **xExchDatabaseAvailabilityGroupMember** adds a member to
  a Database Availability Group.
- **xExchDatabaseAvailabilityGroupNetwork** can add, remove, or configure
  a Database Availability Group Network.
- **xExchEcpVirtualDirectory**
- **xExchEventLogLevel** is used to configure Exchange diagnostic logging via Set-EventLogLevel.
- **xExchExchangeCertificate** can install, remove, or configure
  an ExchangeCertificate using \*-ExchangeCertificate cmdlets.
- **xExchExchangeServer**
- **xExchFrontendTransportService** configures Front End Transport service settings.
- **xExchImapSettings** configures IMAP settings using Set-ImapSettings.
- **xExchInstall** installs or updates Exchange 2013, 2016, or 2019.
- **xExchJetstress** automatically runs Jetstress using
  the **JetstressCmd.exe** command line executable.
- **xExchJetstressCleanup** cleans up the database and log
  directories created by Jetstress.
- **xExchMailboxDatabase**
- **xExchMailboxDatabaseCopy**
- **xExchMailboxTransportService**
- **xExchMailboxServer**
- **xExchMaintenanceMode**
- **xExchMapiVirtualDirectory**
- **xExchOabVirtualDirectory**
- **xExchOutlookAnywhere**
- **xExchOwaVirtualDirectory**
- **xExchPopSettings** configures POP settings using Set-PopSettings.
- **xExchPowerShellVirtualDirectory**
- **xExchReceiveConnector**
- **xExchRemoteDomain** is used to add remote domains
- **xExchSendConnector** is used to add a send connector
- **xExchTransportService**
- **xExchUMCallRouterSettings** configures the UM Call Router service using Set-UMCallRouterSettings.
- **xExchUMService** configures a UM server using Set-UMService.
- **xExchWaitForADPrep** ensures that Active Directory has been prepared for
  Exchange 2013, 2016, or 2019.
- **xExchWaitForDAG**
- **xExchWaitForMailboxDatabase**
- **xExchWebServicesVirtualDirectory**

### xExchAcceptedDomain

- **xExchAcceptedDomain** is used to add accepted domains

- **DomainName** The domain name of the accepted domain
- **Credential**: Credentials used to establish a remote
  PowerShell session to Exchange.
- **Ensure**: Whether the domain should exist or not: { Present | Absent }
- **AddressBookEnabled** Whether to enable recipient filtering for this domain
- **DomainType** Type of the the domain:
  {Authoritative | ExternalRelay | InternalRelay}
- **Default** Whether the accepted domain is the default domain.
- **MatchSubDomains** Enables mail to be sent by and received from users on any
  subdomain
- **Name** Specifies a unique name

### xExchActiveSyncVirtualDirectory

**xExchActiveSyncVirtualDirectory** is used to configure properties on an
ActiveSync Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-ActiveSyncVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-activesyncvirtualdirectory)
parameters.

- **Identity**: The Identity of the ActiveSync Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is okay to recycle the app pool,
  or restart IIS after making changes. Defaults to \$false.
- **AutoCertBasedAuth**: Automates the IIS configuration portion of
  certificate based authentication.
  Only works against the Default Web Site.
  Does not configure ClientCertAuth parameter, which must be specified separately.
  Does not install ?Client Certificate Mapping Authentication? or ?IIS Client
  Certificate Mapping Authentication? roles of IIS,
  which also must be configured separately.
- **AutoCertBasedAuthThumbprint**: The thumbprint of the in use
  Exchange certificate for IIS.
- **AutoCertBasedAuthHttpsBindings**: The (IP:PORT)'s of the HTTPS bindings on
  the Default Web Site. Defaults to "0.0.0.0:443","127.0.0.1:443"
- **ActiveSyncServer**
- **BadItemReportingEnabled**
- **BasicAuthEnabled**
- **ClientCertAuth**
- **CompressionEnabled**
- **DomainController**
- **ExtendedProtectionFlags**
- **ExtendedProtectionSPNList**
- **ExtendedProtectionTokenChecking**
- **ExternalAuthenticationMethods**
- **ExternalUrl**
- **InstallIsapiFilter**
- **InternalAuthenticationMethods**
- **InternalUrl**
- **MobileClientCertificateAuthorityURL**
- **MobileClientCertificateProvisioningEnabled**
- **MobileClientCertTemplateName**
- **Name**
- **RemoteDocumentsActionForUnknownServers**
- **RemoteDocumentsAllowedServers**
- **RemoteDocumentsBlockedServers**
- **RemoteDocumentsInternalDomainSuffixList**
- **SendWatsonReport**
- **WindowsAuthEnabled**: Auto Certificate Based Authentication Requirements:
  For AutoCertBasedAuth to work, the ?Client Certificate Mapping Authentication?
  and ?IIS Client Certificate Mapping Authentication? roles of IIS need to be installed.

#### Common Issues

The parameter Name can be a breaking setting. When you change the name the identity
changes as well. The switch InstallIsapiFilter by the Cmdlet is doing nothing.
Therefore Add-WebConfigurationProperty is used to add a missing IsapiFilter.

### xExchAddressList

- **xExchAddressList** is used to add an address list

- **Name** The name of the address list.
- **Credential** Credentials used to establish a remote PowerShell session to
  Exchange.
- **ConditionalCompany** The ConditionalCompany parameter specifies a precanned
  filter that's based on the value of the recipient's Company property.
- **ConditionalCustomAttribute1** The ConditionalCustomAttribute1 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute1 property.
- **ConditionalCustomAttribute2** The ConditionalCustomAttribute2 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute2 property.
- **ConditionalCustomAttribute3** The ConditionalCustomAttribute3 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute3 property.
- **ConditionalCustomAttribute4** The ConditionalCustomAttribute4 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute4 property.
- **ConditionalCustomAttribute5** The ConditionalCustomAttribute5 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute5 property.
- **ConditionalCustomAttribute6** The ConditionalCustomAttribute6 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute6 property.
- **ConditionalCustomAttribute7** The ConditionalCustomAttribute7 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute7 property.
- **ConditionalCustomAttribute8** The ConditionalCustomAttribute8 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute8 property.
- **ConditionalCustomAttribute9** The ConditionalCustomAttribute9 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute9 property.
- **ConditionalCustomAttribute10** The ConditionalCustomAttribute10 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute10 property.
- **ConditionalCustomAttribute11** The ConditionalCustomAttribute11 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute11 property.
- **ConditionalCustomAttribute12** The ConditionalCustomAttribute12 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute12 property.
- **ConditionalCustomAttribute13** The ConditionalCustomAttribute13 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute13 property.
- **ConditionalCustomAttribute14** The ConditionalCustomAttribute14 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute14 property.
- **ConditionalCustomAttribute15** The ConditionalCustomAttribute15 parameter
  specifies a precanned filter that's based on the value of the recipient's
  ConditionalCustomAttribute15 property.
- **ConditionalDepartment** The ConditionalDepartment parameter specifies a
  precanned filter that's based on the value of the recipient's Department property.
- **ConditionalStateOrProvince** The ConditionalStateOrProvince parameter
  specifies a precanned filter that's based on the value of the recipient's
  StateOrProvince property.
- **Container** The Container parameter specifies where to create the address list.
- **DisplayName** Specifies the displayname.
- **IncludedRecipients** Specifies a precanned filter that's based on the
  recipient type.
- **RecipientContainer** The RecipientContainer parameter specifies a filter
  that's based on the recipient's location in Active Directory.
- **RecipientFilter** The RecipientFilter parameter specifies a custom OPath
  filter that's based on the value of any available recipient property.

### xExchAntiMalwareScanning

**xExchAntiMalwareScanning** is used to enable or disable Exchange Anti-malware scanning.

- **Enabled**: Whether Exchange Anti-malware scanning should be Enabled.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether the Transport services should be
  automatically restarted after a status change.

### xExchAutodiscoverVirtualDirectory

**xExchAutodiscoverVirtualDirectory** is used to configure properties on an
AutoDiscover Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-AutodiscoverVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-autodiscovervirtualdirectory)
parameters.

- **Identity**: The Identity of the Autodiscover Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange
- **AllowServiceRestart**: Whether it is okay to recycle the app pool
  after making changes.Defaults to \$false.
- **BasicAuthEnabled**
- **DigestAuthentication**
- **DomainController**
- **ExtendedProtectionFlags**
- **ExtendedProtectionSPNList**
- **ExtendedProtectionTokenChecking**
- **OAuthAuthentication**
- **WindowsAuthEnabled**
- **WSSecurityAuthentication**

### xExchAutoMountPoint

**xExchAutoMountPoint** is used to automatically find unused disks,
and prepare them for use within AutoReseed. With the disks that are found,
it will assign appropriate volume and database mount points. Once fully configured,
if a disk fails and is replaced with a new disk, xExchAutoMountPoint will
automatically detect it and format and assign an Exchange volume mount point
so that AutoReseed can detect it as a spare disk.

- **Identity**: The name of the server. This is not actually used for anything.
- **AutoDagDatabasesRootFolderPath**: The parent folder for Exchange database
  mount point folders.
- **AutoDagVolumesRootFolderPath**: The parent folder for Exchange volume mount
  point folders.
- **DiskToDBMap**: An array of strings containing the databases for each disk.
  Databases on the same disk should be in the same string, and comma separated.
  Example: "DB1,DB2","DB3,DB4".
  This puts DB1 and DB2 on one disk, and DB3 and DB4 on another.
- **SpareVolumeCount**: How many spare volumes will be available.
- **EnsureExchangeVolumeMountPointIsLast**: Whether the EXVOL mount point
  should be moved to be the last mount point listed on each disk. Defaults
  to \$false.
- **CreateSubfolders**: If $true, specifies that DBNAME.db and DBNAME.log
  subfolders should be automatically created underneath the ExchangeDatabase
  mount points. Defaults to $false.
- **FileSystem**: The file system to use when formatting the volume.
  Defaults to NTFS.
- **MinDiskSize**: The minimum size of a disk to consider using. Defaults to none.
  Should be in a format like "1024MB" or "1TB".
- **PartitioningScheme**: The partitioning scheme for the volume. Defaults to GPT.
- **UnitSize**: The unit size to use when formatting the disk. Defaults to 64k.
  Specified value should end in a number, indicating bytes, or with a k,
  indicating the value is kilobytes.
- **VolumePrefix**: The prefix to give to Exchange Volume folders. Defaults to EXVOL

#### Common Issues

xExchAutoMountPoint will not assign an Exchange database mount point if
the target folder for the database already exists. If initial setup fails,
make sure that the database folders do not already exist. Note that this only
affects database folders. If a volume folder already exists, the resource will
just find the next unused number and assign it to a new volume folder.

### xExchClientAccessServer

**xExchClientAccessServer** is used to configure properties on a Client Access
Server.

Where no description is listed, properties correspond directly to
[Set-ClientAccessService](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-clientaccessservice)
parameters.

- **Identity**: The hostname of the Client Access Server.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AutoDiscoverServiceInternalUri**
- **AutoDiscoverSiteScope**
- **DomainController**
- **AlternateServiceAccountCredential**
- **CleanUpInvalidAlternateServiceAccountCredentials**
- **RemoveAlternateServiceAccountCredentials**

### xExchDatabaseAvailabilityGroup

**xExchDatabaseAvailabilityGroup** configures a Database Availability Group
using New/Set-DatabaseAvailibilityGroup. Only a single node in a configuration
script should implement this resource. All DAG nodes, including the node
implementing **xExchDatabaseAvailabilityGroup**, should use
**xExchDatabaseAvailabilityGroupMember** to join a DAG.

Where no description is listed, properties correspond directly to
[Set-DatabaseAvailabilityGroup](https://docs.microsoft.com/en-us/powershell/module/exchange/database-availability-groups/set-databaseavailabilitygroup)
parameters.

- **Name**: The name of the Database Availability Group.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AutoDagTotalNumberOfServers**: Required to determine when all DAG members
  have been added. DatacenterActivationMode will not be set until that occurs.
- **AlternateWitnessDirectory**
- **AlternateWitnessServer**
- **AutoDagAutoRedistributeEnabled**
- **AutoDagAutoReseedEnabled**
- **AutoDagDatabaseCopiesPerDatabase**
- **AutoDagDatabaseCopiesPerVolume**
- **AutoDagDatabasesRootFolderPath**
- **AutoDagDiskReclaimerEnabled**
- **AutoDagTotalNumberOfDatabases**
- **AutoDagVolumesRootFolderPath**
- **DatabaseAvailabilityGroupIpAddresses**
- **DatacenterActivationMode**
- **DomainController**
- **FileSystem**
- **ManualDagNetworkConfiguration**
- **NetworkCompression**
- **NetworkEncryption**
- **PreferenceMoveFrequency**
- **ReplayLagManagerEnabled**
- **ReplicationPort**
- **WitnessDirectory**
- **WitnessServer**
- **SkipDagValidation**

#### Common Issues

DAG creation will fail if the computer account of the node managing the DAG does
not have permissions to create computers in Active Directory.
To avoid this issue, you may need to
[make sure that the computer account for the DAG is prestaged](<http://technet.microsoft.com/en-us/library/ff367878(v=exchg.150).aspx>).
To disable PreferenceMoveFrequency you have to use the following value:
"\$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())"

### xExchDatabaseAvailabilityGroupMember

**xExchDatabaseAvailabilityGroupMember** adds a member to a Database
Availability Group. This must be implemented by all nodes, including the one
that creates and maintains the DAG.

Where no description is listed, properties correspond directly to
[Add-DatabaseAvailabilityGroupServer](https://docs.microsoft.com/en-us/powershell/module/exchange/database-availability-groups/add-databaseavailabilitygroupserver)
parameters.

- **MailboxServer**: The hostname of the server to add to the DAG.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **DAGName**: The name of the DAG to add the member to.
- **DomainController**
- **SkipDagValidation**

### xExchDatabaseAvailabilityGroupNetwork

**xExchDatabaseAvailabilityGroupNetwork** can add, remove, or configure
a Database Availability Group Network.
This should only be implemented by a single node in the DAG.

Where no description is listed, properties correspond directly to
[Set-DatabaseAvailabilityGroupNetwork](https://docs.microsoft.com/en-us/powershell/module/exchange/database-availability-groups/Set-DatabaseAvailabilityGroupNetwork)
parameters.

- **Name**: The name of the DAG network
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **DatabaseAvailabilityGroup**: The name of the DAG where the network exists.
- **Ensure**: Whether the DAG network should exist or not: { Present | Absent }
- **Description**
- **DomainController**
- **IgnoreNetwork**
- **ReplicationEnabled**
- **Subnets**

### xExchEcpVirtualDirectory

**xExchEcpVirtualDirectory** is used to configure properties on an Exchange
Control Panel Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-EcpVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-ecpvirtualdirectory)
parameters.

- **Identity**: The Identity of the ECP Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to recycle the app pool after making
  changes. Defaults to \$false.
- **AdfsAuthentication**
- **AdminEnabled**
- **BasicAuthentication**
- **DigestAuthentication**
- **DomainController**
- **ExternalAuthenticationMethods**
- **FormsAuthentication**
- **GzipLevel**
- **ExternalUrl**
- **InternalUrl**
- **WindowsAuthentication**
- **WSSecurityAuthentication**

### xExchEventLogLevel

**xExchEventLogLevel** is used to configure Exchange diagnostic logging via
Set-EventLogLevel.

Properties correspond to
[Set-EventLogLevel](https://docs.microsoft.com/en-us/powershell/module/exchange/server-health-and-performance/set-eventloglevel)
parameters.

- **Identity**: The Identity parameter specifies the name of the event logging
  category for which you want to set the event logging level.
  Do not specify servername within the Identity.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **Level**: The Level parameter specifies the log level for the specific event
  logging category. Valid values are Lowest, Low, Medium, High, and Expert.

### xExchExchangeCertificate

**xExchExchangeCertificate** can install, remove, or configure
an ExchangeCertificate using \*-ExchangeCertificate cmdlets.

- **Thumbprint**: The Thumbprint of the Exchange Certificate to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **Ensure**: Whether the Exchange Certificate should exist or not:
  { Present | Absent }
- **AllowExtraServices**: Get-ExchangeCertificate sometimes displays
  more services than are actually enabled.
  Setting this to true allows tests to pass in that situation as long as
  the requested services are present.
- **CertCreds**: Credentials containing the password to the .pfx file in CertFilePath.
- **CertFilePath**: The file path to the certificate .pfx file that should be imported.
- **DomainController**: Domain Controller to talk to.
- **DoNotRequireSsl**: Setting DoNotRequireSsl to True prevents DSC from
  enabling the Require SSL setting on the Default Web Site when you enable the
  certificate for IIS. Defaults to False.
- **NetworkServiceAllowed**: Setting NetworkServiceAllowed to True gives the
  built-in Network Service account permission to read the certificate's private
  key without enabling the certificate for SMTP. Defaults to False.
- **Services**: Services to enable on the certificate.
  See [Enable-ExchangeCertificate](https://docs.microsoft.com/en-us/powershell/module/exchange/encryption-and-certificates/enable-exchangecertificate)
  documentation.

### xExchExchangeServer

**xExchExchangeServer** is used to configure properties on an Exchange Server
via Set-ExchangeServer.

Most properties correspond directly to properties in
[Set-ExchangeServer](https://docs.microsoft.com/en-us/powershell/module/exchange/organization/set-exchangeserver)
parameters.

- **Identity**: The Identity parameter specifies the GUID, distinguished name
  (DN), or name of the server.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **AllowServiceRestart**: Whether it is OK to restart the Information Store
  service after licensing the server. Defaults to \$false.
- **CustomerFeedbackEnabled**: The CustomerFeedbackEnabled parameter specifies
  whether the Exchange server is enrolled in the Microsoft Customer Experience
  Improvement Program (CEIP). The CEIP collects anonymous information about how
  you use Exchange and problems that you might encounter. If you decide not to
  participate in the CEIP, the servers are opted-out automatically.
- **DomainController**: The DomainController parameter specifies the domain
  controller that's used by this cmdlet to read data from or write data to
  Active Directory. You identify the domain controller by its fully qualified
  domain name (FQDN). For example, dc01.contoso.com.
- **ErrorReportingEnabled**: The ErrorReportingEnabled parameter specifies
  whether error reporting is enabled.
- **InternetWebProxy**: The InternetWebProxy parameter specifies the web proxy
  server that the Exchange server uses to reach the internet. A valid value for
  this parameter is the URL of the web proxy server.
- **InternetWebProxyBypassList**: The InternetWebProxyBypassList parameter
  specifies a list of servers that bypass the web proxy server specified by the
  InternetWebProxy parameter. You identify the servers by their FQDN (for
  example, server01.contoso.com).
- **MonitoringGroup**: The MonitoringGroup parameter specifies how to add your
  Exchange servers to monitoring groups. You can add your servers to an
  existing group or create a monitoring group based on location or deployment,
  or to partition monitoring responsibility among your servers.
- **ProductKey**: The ProductKey parameter specifies the server product key.
- **StaticConfigDomainController**: The StaticConfigDomainController parameter
  specifies whether to configure a domain controller to be used by the server
  via Directory Service Access (DSAccess).
- **StaticDomainControllers**: The StaticDomainControllers parameter specifies
  whether to configure a list of domain controllers to be used by the server
  via DSAccess.
- **StaticExcludedDomainControllers**: The StaticExcludedDomainControllers
  parameter specifies whether to exclude a list of domain controllers from
  being used by the server.
- **StaticGlobalCatalogs**: The StaticGlobalCatalogs parameter specifies
  whether to configure a list of global catalogs to be used by the server via
  DSAccess.
- **WorkloadManagementPolicy**: The _-ResourcePolicy,
  _-WorkloadManagementPolicy and \*-WorkloadPolicy system workload management
  cmdlets have been deprecated. System workload management settings should be
  customized only under the direction of Microsoft Customer Service and
  Support.

### xExchFrontendTransportService

**xExchFrontendTransportService** configures the Front End Transport service
settings on Mailbox servers or Edge Transport servers using
Set-FrontendTransportService.

Most properties correspond directly to properties in
[Set-FrontendTransportService](https://docs.microsoft.com/en-us/powershell/module/exchange/mail-flow/Set-FrontendTransportService)
parameters.

- **Identity**: Hostname of the server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **AllowServiceRestart**: Whether it is OK to restart the
  MSExchangeFrontEndTransport service after making changes. Defaults to \$false.
- **AgentLogEnabled**: The AgentLogEnabled parameter specifies whether the
  agent log is enabled. The default value is \$true.
- **AgentLogMaxAge**: The AgentLogMaxAge parameter specifies the maximum age
  for the agent log file. Log files older than the specified value are deleted.
  The default value is 7.00:00:00 or 7 days.
- **AgentLogMaxDirectorySize**: The AgentLogMaxDirectorySize parameter
  specifies the maximum size of all agent logs in the agent log directory. When a
  directory reaches its maximum file size, the server deletes the oldest log
  files first. The default value is 250 MB.
- **AgentLogMaxFileSize**: The AgentLogMaxFileSize parameter specifies the
  maximum size of each agent log file. When a log file reaches its maximum file
  size, a new log file is created. The default value is 10 MB.
- **AgentLogPath**: The AgentLogPath parameter specifies the default agent log
  directory location.
- **AntispamAgentsEnabled**: The AntispamAgentsEnabled parameter specifies
  whether anti-spam agents are installed on the server specified with the
  Identity parameter. The default value is \$false for the Front End Transport
  service.
- **ConnectivityLogEnabled**: The ConnectivityLogEnabled parameter specifies
  whether the connectivity log is enabled. The default value is \$true.
- **ConnectivityLogMaxAge**: The ConnectivityLogMaxAge parameter specifies the
  maximum age for the connectivity log file. Log files older than the specified
  value are deleted. The default value is 30 days.
- **ConnectivityLogMaxDirectorySize**: The ConnectivityLogMaxDirectorySize
  parameter specifies the maximum size of all connectivity logs in the
  connectivity log directory. When a directory reaches its maximum file size, the
  server deletes the oldest log files first. The default value is 1000 MB.
- **ConnectivityLogMaxFileSize**: The ConnectivityLogMaxFileSize parameter
  specifies the maximum size of each connectivity log file. When a log file
  reaches its maximum file size, a new log file is created. The default value is
  10 MB.
- **ConnectivityLogPath**: The ConnectivityLogPath parameter specifies the
  default connectivity log directory location.
- **DnsLogEnabled**: The DnsLogEnabled parameter specifies whether the DNS log
  is enabled. The default value is \$false.
- **DnsLogMaxAge**: The DnsLogMaxAge parameter specifies the maximum age for
  the DNS log file. Log files older than the specified value are deleted. The
  default value is 7.00:00:00 or 7 days.
- **DnsLogMaxDirectorySize**: The DnsLogMaxDirectorySize parameter specifies
  the maximum size of all DNS logs in the DNS log directory. When a directory
  reaches its maximum file size, the server deletes the oldest log files first.
  The default value is 100 MB.
- **DnsLogMaxFileSize**: The DnsLogMaxFileSize parameter specifies the maximum
  size of each DNS log file. When a log file reaches its maximum file size, a new
  log file is created. The default value is 10 MB.
- **DnsLogPath**: DnsLogPath parameter specifies the DNS log directory
  location. The default value is blank (\$null), which indicates no location is
  configured. If you enable DNS logging, you need to specify a local file path
  for the DNS log files by using this parameter.
- **ExternalDNSAdapterEnabled**: The ExternalDNSAdapterEnabled parameter
  specifies one or more Domain Name System (DNS) servers that Exchange uses for
  external DNS lookups.
- **ExternalDNSAdapterGuid**: The ExternalDNSAdapterGuid parameter specifies
  the network adapter that has the DNS settings used for DNS lookups of
  destinations that exist outside the Exchange organization.
- **ExternalDNSProtocolOption**: The ExternalDNSProtocolOption parameter
  specifies which protocol to use when querying external DNS servers. The valid
  options for this parameter are Any, UseTcpOnly, and UseUdpOnly. The default
  value is Any.
- **ExternalDNSServers**: The ExternalDNSServers parameter specifies the list
  of external DNS servers that the server queries when resolving a remote domain.
  You must separate IP addresses by using commas. The default value is an empty
  list ({}).
- **ExternalIPAddress**: The ExternalIPAddress parameter specifies the IP
  address used in the Received message header field for every message that
  travels through the Front End Transport service.
- **InternalDNSAdapterEnabled**: The InternalDNSAdapterEnabled parameter
  specifies one or more DNS servers that Exchange uses for internal DNS lookups.
- **InternalDNSAdapterGuid**: The InternalDNSAdapterGuid parameter specifies
  the network adapter that has the DNS settings used for DNS lookups of servers
  that exist inside the Exchange organization.
- **InternalDNSProtocolOption**: The InternalDNSProtocolOption parameter
  specifies which protocol to use when you query internal DNS servers. Valid
  options for this parameter are Any, UseTcpOnly, or UseUdpOnly. The default
  value is Any.
- **InternalDNSServers**: The InternalDNSServers parameter specifies the list
  of DNS servers that should be used when resolving a domain name. DNS servers
  are specified by IP address and are separated by commas. The default value is
  any empty list ({}).
- **IntraOrgConnectorProtocolLoggingLevel**: The
  IntraOrgConnectorProtocolLoggingLevel parameter enables or disables SMTP
  protocol logging on the implicit and invisible intra-organization Send
  connector in the Front End Transport service.
- **MaxConnectionRatePerMinute**: The MaxConnectionRatePerMinute parameter
  specifies the maximum rate that connections are allowed to be opened with the
  transport service.
- **ReceiveProtocolLogMaxAge**: The ReceiveProtocolLogMaxAge parameter
  specifies the maximum age of a protocol log file that's shared by all Receive
  connectors in the Transport service on the server. Log files that are older
  than the specified value are automatically deleted.
- **ReceiveProtocolLogMaxDirectorySize**: The
  ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum size of the
  protocol log directory that's shared by all Receive connectors in the Front End
  Transport service on the server. When the maximum directory size is reached,
  the server deletes the oldest log files first.
- **ReceiveProtocolLogMaxFileSize**: The ReceiveProtocolLogMaxFileSize
  parameter specifies the maximum size of a protocol log file that's shared by
  all Receive connectors in the Front End Transport service on the server. When a
  log file reaches its maximum file size, a new log file is created.
- **ReceiveProtocolLogPath**: The ReceiveProtocolLogPath parameter specifies
  the location of the protocol log directory for all Receive connectors in the
  Front End Transport service on the server.
- **RoutingTableLogMaxAge**: The RoutingTableLogMaxAge parameter specifies the
  maximum routing table log age. Log files older than the specified value are
  deleted. The default value is 7 days.
- **RoutingTableLogMaxDirectorySize**: The RoutingTableLogMaxDirectorySize
  parameter specifies the maximum size of the routing table log directory. When
  the maximum directory size is reached, the server deletes the oldest log files
  first. The default value is 250 MB.
- **RoutingTableLogPath**: The RoutingTableLogPath parameter specifies the
  directory location where routing table log files should be stored.
- **SendProtocolLogMaxAge**: The SendProtocolLogMaxAge parameter specifies the
  maximum age of a protocol log file that's shared by all Send connectors in the
  Front End Transport service that have this server configured as a source
  server. Log files that are older than the specified value are deleted.
- **SendProtocolLogMaxDirectorySize**: The SendProtocolLogMaxDirectorySize
  parameter specifies the maximum size of the protocol log directory that's
  shared by all Send connectors in the Front End Transport service that have this
  server configured as a source server. When the maximum directory size is
  reached, the server deletes the oldest log files first.
- **SendProtocolLogMaxFileSize**: The SendProtocolLogMaxFileSize parameter
  specifies the maximum size of a protocol log file that's shared by all the Send
  connectors in the Front End Transport service that have this server configured
  as a source server. When a log file reaches its maximum file size, a new log
  file is created.
- **SendProtocolLogPath**: The SendProtocolLogPath parameter specifies the
  location of the protocol log directory for all Send connectors in the Front End
  Transport service that have this server configured as a source server.
- **TransientFailureRetryCount**: The TransientFailureRetryCount parameter
  specifies the maximum number of immediate connection retries attempted when the
  server encounters a connection failure with a remote server. The default value
  is 6. The valid input range for this parameter is from 0 through 15. When the
  value of this parameter is set to 0, the server doesn't immediately attempt to
  retry an unsuccessful connection.
- **TransientFailureRetryInterval**: The TransientFailureRetryInterval
  parameter controls the connection interval between each connection attempt
  specified by the TransientFailureRetryCount parameter. For the Front End
  Transport service, the default value of the TransientFailureRetryInterval
  parameter is 5 minutes.

#### Common Issues

To set some settings to NULL you need to set the value to '' instead of using \$null.
The following settings are affected:
ExternalDNSServers
ExternalIPAddress
InternalDNSServers

### xExchImapSettings

**xExchImapSettings** configures IMAP settings using Set-ImapSettings.

Most properties correspond directly to properties in
[Set-ImapSettings](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access/set-imapsettings)
parameters.

- **Server**: Hostname of the IMAP server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **AllowServiceRestart**: Whether it is OK to restart the IMAP services after
  making changes. Defaults to \$false.
- **DomainController**: The DomainController parameter specifies the domain
  controller that's used by this cmdlet to read data from or write data to
  Active Directory. You identify the domain controller by its fully qualified
  domain name (FQDN). For example, dc01.contoso.com.
- **ExternalConnectionSettings**: The ExternalConnectionSettings parameter
  specifies the host name, port, and encryption method that's used by external
  IMAP4 clients (IMAP4 connections from outside your corporate network).
- **LoginType**: The LoginType parameter specifies the authentication method
  for IMAP4 connections.
- **X509CertificateName**: The X509CertificateName parameter specifies the
  certificate that's used for encrypting IMAP4 client connections.
- **AuthenticatedConnectionTimeout**: The AuthenticatedConnectionTimeout
  parameter specifies the period of time to wait before closing an idle
  authenticated connection.")] String AuthenticatedConnectionTimeout.
- **Banner**: The Banner parameter specifies the text string that's displayed to
  connecting IMAP4 clients.
- **CalendarItemRetrievalOption**: The CalendarItemRetrievalOption parameter
  specifies how calendar items are presented to IMAP4 clients.
  {iCalendar | IntranetUrl | InternetUrl | Custom}
- **EnableExactRFC822Size**: The EnableExactRFC822Size parameter specifies how
  message sizes are presented to IMAP4 clients.
- **EnableGSSAPIAndNTLMAuth**: The EnableGSSAPIAndNTLMAuth parameter specifies
  whether connections can use Integrated Windows authentication (NTLM) using the
  Generic Security Services application programming interface (GSSAPI). This
  setting applies to connections where Transport Layer Security (TLS) is disabled.
- **EnforceCertificateErrors**: The EnforceCertificateErrors parameter specifies
  whether to enforce valid Secure Sockets Layer (SSL) certificate validation failures.
- **ExtendedProtectionPolicy**: The ExtendedProtectionPolicy parameter specifies
  how Extended Protection for Authentication is used. {None | Allow | Required}
- **InternalConnectionSettings**: The InternalConnectionSettings parameter
  specifies the host name, port, and encryption method that's used by internal
  IMAP4 clients (IMAP4 connections from inside your corporate network).
- **LogFileLocation**: The LogFileLocation parameter specifies the location for
  the IMAP4 protocol log files.
- **LogFileRollOverSettings**: The LogFileRollOverSettings parameter specifies
  how frequently IMAP4 protocol logging creates a new log file.
  {Hourly | Daily | Weekly | Monthly}
- **LogPerFileSizeQuota**: The LogPerFileSizeQuota parameter specifies the
  maximum size of a IMAP4 protocol log file.
- **MaxCommandSize**: The MaxCommandSize parameter specifies the maximum size in
  bytes of a single IMAP4 command.
- **MaxConnectionFromSingleIP**: The MaxConnectionFromSingleIP parameter
  specifies the maximum number of IMAP4 connections that are accepted by the
  Exchange server from a single IP address.
- **MaxConnections**: The MaxConnections parameter specifies the maximum number
  of IMAP4 connections that are accepted by the Exchange server.
- **MaxConnectionsPerUser**: The MaxConnectionsPerUser parameter specifies the
  maximum number of IMAP4 connections that are allowed for each user.
- **MessageRetrievalMimeFormat**: The MessageRetrievalMimeFormat parameter
  specifies the MIME encoding of messages.
  {TextOnly | HtmlOnly | HtmlAndTextAlternative |
  TextEnrichedOnly | TextEnrichedAndTextAlternative | BestBodyFormat | Tnef}
- **OwaServerUrl**: The OwaServerUrl parameter specifies the URL that's used to
  retrieve calendar information for instances of custom Outlook on the web
  calendar items.
- **PreAuthenticatedConnectionTimeout**: The PreAuthenticatedConnectionTimeout
  parameter specifies the period of time to wait before closing an idle IMAP4
  connection that isn't authenticated.
- **ProtocolLogEnabled**: The ProtocolLogEnabled parameter specifies whether to
  enable protocol logging for IMAP4.
- **ProxyTargetPort**: The ProxyTargetPort parameter specifies the port on the
  Microsoft Exchange IMAP4 Backend service that listens for client connections
  that are proxied from the Microsoft Exchange IMAP4 service.
- **ShowHiddenFoldersEnabled**: The ShowHiddenFoldersEnabled parameter specifies
  whether hidden mailbox folders are visible.
- **SSLBindings**: The SSLBindings parameter specifies the IP address and TCP
  port that's used for IMAP4 connection that's always encrypted by SSL/TLS. This
  parameter uses the syntax {IPv4OrIPv6Address}:{Port}.
- **SuppressReadReceipt**: The SuppressReadReceipt parameter specifies whether
  to stop duplicate read receipts from being sent to IMAP4 clients that have the
  Send read receipts for messages I send setting configured in their IMAP4 email
  program.
- **UnencryptedOrTLSBindings**: The X509CertificateName parameter specifies the
  certificate that's used for encrypting IMAP4 client connections.

### xExchInstall

**xExchInstall** installs or updates Exchange 2013, 2016, or 2019.

- **Path**: Full path to setup.exe in the Exchange 2013, 2016, or 2019
  setup directory.
- **Arguments**: Command line arguments to pass to setup.exe
  For help on command line arguments, see
  [Install Exchange 2016 using unattended mode](https://docs.microsoft.com/en-us/Exchange/plan-and-deploy/deploy-new-installations/unattended-installs)
- **Credential**: The credentials to use to perform the installation.

### xExchJetstress

**xExchJetstress** automatically runs Jetstress using the **JetstressCmd.exe**
command line executable. The resource launches Jetstress via a Scheduled Task,
then monitors for JetstressCmd.exe to determine whether Jetstress is running.
Once JetstressCmd.exe has finished, xExchJetstress looks for the existence of
**TYPE\*.html** files in the Jetstress installation directory to determine whether
Jetstress has already been run, or if it needs to be executed.
**TYPE** corresponds to the Type defined in the **JetstressConfig.xml** file,
where valid values are **Performance**, **Stress**, **DatabaseBackup**, or **SoftRecovery**.
If TYPE*.html files exist, the newest file is inspected to determine whether
the Jetstress run resulted in a **Pass** or **Fail**.
Note that a \*\*TYPE*.html** file is not written until Jetstress has finished
its initialization phase, and has also finished the testing phase with either
a **Pass** or a **Fail\*\*.
A crash of the JetstressCmd.exe process will also prevent the file from being written.

- **Type**: Specifies the Type which was defined in the JetstressConfig.xml
  file:{ Performance | Stress | DatabaseBackup | SoftRecovery }
- **JetstressPath**: The path to the folder where Jetstress is installed,
  and which contains JetstressCmd.exe.
- **JetstressParams**: Command line parameters to pass into JetstressCmd.exe.
- **MaxWaitMinutes**: The maximum amount of time that the Scheduled Task which
  runs Jetstress can execute for.
  Defaults to 0, which means there is no time limit.
- **MinAchievedIOPS**: The minimum value reported in the
  'Achieved Transactional I/O per Second' section of the Jetstress report
  for the run to be considered successful.
  Defaults to 0.
- **WARNING 1:** Jetstress should **NEVER** be run on a server that already
  has Exchange installed.
  Jetstress is only meant to be used for pre-installation server validation.
  As such, it is recommended that **xExchJetstress** be used in a one time script
  which is separate from the script that performs ongoing server configuration validation.
- **WARNING 2:** **xExchJetstress** should **NOT** be used in the same
  configuration script as **xExchJetstressCleanup**.
  Instead, they should be run in separate scripts.
  Because **xExchJetstress** looks for files and folders that may have been
  cleaned up by **xExchJetstressCleanup**, using them in the same script
  may result in a configuration loop.

### xExchJetstressCleanup

xExchJetstressCleanup cleans up the database and log directories created by Jetstress.
It can optionally remove mount points associated with those directories,
and can also remove the Jetstress binaries.
Note that **xExchJetstressCleanup** does **NOT** uninstall Jetstress.
That can be accomplished using the **Package** resource which is built into DSC.

- **JetstressPath**: The path to the folder where Jetstress is installed,
  which contains **JetstressCmd.exe**.
- **\*ConfigFilePath**: The full path to **JetstressConfig.xml**,
  which will be used to determine the database and log folders that need to be removed.
- **\*DatabasePaths**: Specifies the paths to database directories that
  should be cleaned up.
- **DeleteAssociatedMountPoints**: Indicates that the mount points associated
  with the Jetstress database and log paths should be removed.
  Defaults to \$false.
  Does not remove EXVOL mount points.
- **\*LogPaths**: Specifies the paths to log directories that should be cleaned up.
- **RemoveBinaries**: Specifies that the files located in **JetstressPath**
  should be removed.
  If **ConfigFilePath** is also specified and JetstressConfig.xml is in the
  same directory as JetstressPath, all files will be removed from the directory
  except JetstressConfig.xml.
- **OutputSaveLocation**: If **RemoveBinaries** is set to \$true and Jetstress
  output was saved to the default location (**JetstressPath**), this specifies
  the folder path to copy the Jetstress output files to.

Note: Either **ConfigFilePath**, or **DatabasePaths** AND **LogPaths** MUST be
specified. **ConfigFilePath** takes precedence over **DatabasePaths** and **LogPaths**.

**WARNING:** **xExchJetstress** should NOT be used in the same configuration
script as **xExchJetstressCleanup**.
Instead, they should be run in separate scripts.
Because **xExchJetstress** looks for files and folders that may have been
cleaned up by **xExchJetstressCleanup**, using them in the same script may
result in a configuration loop.

### xExchMailboxDatabase

**xExchMailboxDatabase** is used to create, remove, or change properties on a
Mailbox Database.

Most properties correspond directly to
[Set-MailboxDatabase](https://docs.microsoft.com/en-us/powershell/module/exchange/mailbox-databases-and-servers/set-mailboxdatabase)
parameters.

- **Name**: The Name parameter specifies the unique name of the mailbox
  database.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **DatabaseCopyCount**: The number of copies that the database will have once
  fully configured. If circular logging is configured, it will not be enabled
  until this number of copies is met.
- **EdbFilePath**: The EdbFilePath parameter specifies the path to the database
  files.
- **LogFolderPath**: The LogFolderPath parameter specifies the folder location
  for log files.
- **Server**: The Server parameter specifies the server on which you want to
  create the database.
- **AllowFileRestore**: The AllowFileRestore parameter specifies whether to
  allow a database to be restored from a backup.
- **AllowServiceRestart**: Whether it is okay to restart the Information Store
  Service after adding a database. Defaults to \$false.
- **AutoDagExcludeFromMonitoring**: The AutoDagExcludedFromMonitoringparameter
  specifies whether to exclude the mailbox database from the
  ServerOneCopyMonitor, which alerts an administrator when a replicated
  database has only one healthy copy available.
- **BackgroundDatabaseMaintenance**: The BackgroundDatabaseMaintenance
  parameter specifies whether the Extensible Storage Engine (ESE) performs
  database maintenance.
- **CalendarLoggingQuota**: The CalendarLoggingQuota parameter specifies the
  maximum size of the log in the Recoverable Items folder of the mailbox that
  stores changes to calendar items.
- **CircularLoggingEnabled**: The CircularLoggingEnabled parameter specifies
  whether circular logging is enabled for the database. NOTE: Will not be
  enabled until the number of copies specified in DatabaseCopyCount have been
  added.
- **DataMoveReplicationConstraint**: The DataMoveReplicationConstraint
  parameter specifies the throttling behavior for high availability mailbox
  moves.
- **DeletedItemRetention**: The DeletedItemRetention parameter specifies the
  length of time to keep deleted items in the Recoverable Items\Deletions
  folder in mailboxes.
- **DomainController**: The DomainController parameter specifies the domain
  controller that's used by this cmdlet to read data from or write data to
  Active Directory. You identify the domain controller by its fully qualified
  domain name (FQDN). For example, dc01.contoso.com.
- **EventHistoryRetentionPeriod**: The EventHistoryRetentionPeriod parameter
  specifies the length of time to keep event data.
- **IndexEnabled**: The IndexEnabled parameter specifies whether Exchange
  Search indexes the mailbox database.
- **IsExcludedFromProvisioning**: The IsExcludedFromProvisioning parameter
  specifies whether to exclude the database from the mailbox provisioning load
  balancer that distributes new mailboxes randomly and evenly across the
  available databases.
- **IsExcludedFromProvisioningByOperator**: The
  IIsExcludedFromProvisioningByOperator parameter specifies whether to exclude
  the database from the mailbox provisioning load balancer that distributes new
  mailboxes randomly and evenly across the available databases.
- \*_IsExcludedFromProvisioningDueToLogicalCorruption_: The
  IsExcludedFromProvisioningDueToLogicalCorruption parameter specifies whether
  to exclude the database from the mailbox provisioning load balancer that
  distributes new mailboxes randomly and evenly across the available databases.
- **IsExcludedFromProvisioningReason**: The IsExcludedFromProvisioningReason
  parameter specifies the reason why you excluded the mailbox database from the
  mailbox provisioning load balancer.
- **IssueWarningQuota**: The IssueWarningQuota parameter specifies the warning
  threshold for the size of the mailbox.
- **IsSuspendedFromProvisioning**: The IsSuspendedFromProvisioning parameter
  specifies whether to exclude the database from the mailbox provisioning load
  balancer that distributes new mailboxes randomly and evenly across the
  available databases.
- **JournalRecipient**: The JournalRecipient parameter specifies the journal
  recipient to use for per-database journaling for all mailboxes on the
  database.
- **MailboxRetention**: The MailboxRetention parameter specifies the length of
  time to keep deleted mailboxes before they are permanently deleted or purged.
- **MetaCacheDatabaseMaxCapacityInBytes**: The
  MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of the
  metacache database in bytes. To convert gigabytes to bytes, multiply the
  value by 1024^3. For terabytes to bytes, multiply by 1024^4.
- **MountAtStartup**: The MountAtStartup parameter specifies whether to mount
  the mailbox database when the Microsoft Exchange Information Store service
  starts.
- **OfflineAddressBook**: The OfflineAddressBook parameter specifies the
  offline address book that's associated with the mailbox database.
- **ProhibitSendQuota**: The ProhibitSendQuota parameter specifies a size limit
  for the mailbox. If the mailbox reaches or exceeds this size, the mailbox
  can't send new messages, and the user receives a descriptive warning message.
- **ProhibitSendReceiveQuota**: The ProhibitSendReceiveQuota parameter
  specifies a size limit for the mailbox. If the mailbox reaches or exceeds
  this size, the mailbox can't send or receive new messages. Messages sent to
  the mailbox are returned to the sender with a descriptive error message. This
  value effectively determines the maximum size of the mailbox.
- **RecoverableItemsQuota**: The RecoverableItemsQuota parameter specifies the
  maximum size for the Recoverable Items folder of the mailbox.
- **RecoverableItemsWarningQuota**: The RecoverableItemsWarningQuota parameter
  specifies the warning threshold for the size of the Recoverable Items folder
  for the mailbox.
- **RetainDeletedItemsUntilBackup**: The RetainDeletedItemsUntilBackup
  parameter specifies whether to keep items in the Recoverable Items\Deletions
  folder of the mailbox until the next database backup occurs.
- **SkipInitialDatabaseMount**: Whether the initial mount of databases should
  be skipped after database creation.

### xExchMailboxDatabaseCopy

**xExchMailboxDatabaseCopy** is used to create, remove, or change properties on
a Mailbox Database Copy.

Most properties correspond directly to
[Add-MailboxDatabaseCopy](https://docs.microsoft.com/en-us/powershell/module/exchange/database-availability-groups/add-mailboxdatabasecopy)
or
[Set-MailboxDatabaseCopy](https://docs.microsoft.com/en-us/powershell/module/exchange/database-availability-groups/set-mailboxdatabasecopy)
parameters.

- **Identity**: The Identity parameter specifies the name of the database whose
  copy is being modified.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **MailboxServer**: The MailboxServer parameter specifies the name of the
  server that will host the database copy.
- **AdServerSettingsPreferredServer**: An optional domain controller to pass to
  Set-AdServerSettings -PreferredServer.
- **AllowServiceRestart**: Whether it is OK to restart the Information Store.
  service after adding a database copy.
  Defaults to \$false.
- **ActivationPreference**: The ActivationPreference parameter value is used as
  part of Active Manager's best copy selection process and to redistribute
  active mailbox databases throughout the database availability group (DAG)
  when using the RedistributeActiveDatabases.ps1 script.
- **DomainController**: The DomainController parameter specifies the domain
  controller that's used by this cmdlet to read data from or write data to
  Active Directory. You identify the domain controller by its fully qualified
  domain name (FQDN). For example, dc01.contoso.com.
- **ReplayLagMaxDelay**: The ReplayLagMaxDelay parameter specifies the maximum
  delay for lagged database copy play down (also known as deferred lagged copy
  play down).
- **ReplayLagTime**: The ReplayLagTime parameter specifies the amount of time
  that the Microsoft Exchange Replication service should wait before replaying
  log files that have been copied to the passive database copy.
- **SeedingPostponed**: The SeedingPostponed switch specifies that the task
  doesn't seed the database copy, so you need to explicitly seed the database
  copy.
- **TruncationLagTime**: The TruncationLagTime parameter specifies the amount
  of time that the Microsoft Exchange Replication service should wait before
  truncating log files that have replayed into the passive copy of the
  database.

### xExchMailboxServer

**xExchMailboxServer** is used to configure Mailbox Server properties via
Set-MailboxServer.

Properties correspond to
[Set-MailboxServer](https://docs.microsoft.com/en-us/powershell/module/exchange/mailbox-databases-and-servers/set-mailboxserver)
parameters.

- **Identity**: The Identity parameter specifies the Mailbox server
  that you want to modify.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AutoDatabaseMountDial**: The AutoDatabaseMountDial parameter specifies the
  automatic database mount behavior for a continuous replication environment
  after a database failover.
- **CalendarRepairIntervalEndWindow**: The CalendarRepairIntervalEndWindow parameter
  specifies the number of days into the future to repair calendars.
  For example, if this parameter is set to 90, the Calendar Repair Assistant
  repairs calendars on this Mailbox server 90 days from now.
- **CalendarRepairLogDirectorySizeLimit**: The CalendarRepairLogDirectorySizeLimit
  parameter specifies the size limit for all log files for the Calendar Repair Assistant.
  After the limit is reached, the oldest files are deleted.
- **CalendarRepairLogEnabled**: The CalendarRepairLogEnabled parameter specifies
  whether the Calendar Repair Attendant logs items that it repairs.
  The repair log doesn't contain failed repair attempts.
- **CalendarRepairLogFileAgeLimit**: The CalendarRepairLogFileAgeLimit parameter
  specifies how long to retain calendar repair logs. Log files that exceed
  the maximum retention period are deleted.
- **CalendarRepairLogPath**: The CalendarRepairLogPath parameter specifies
  the location of the calendar repair log files on the Mailbox server.
- **CalendarRepairLogSubjectLoggingEnabled**: The CalendarRepairLogSubjectLoggingEnabled
  parameter specifies that the subject of the repaired calendar item is logged in
  the calendar repair log.
- **CalendarRepairMissingItemFixDisabled**: The CalendarRepairMissingItemFixDisabled
  parameter specifies that the Calendar Repair Assistant won't fix missing attendee
  calendar items for mailboxes homed on this Mailbox server.
- **CalendarRepairMode**: The CalendarRepairMode parameter specifies the mode that
  the Calendar Repair Assistant will run in.
- **CalendarRepairWorkCycle**: The CalendarRepairWorkCycle parameter specifies
  the time span in which all mailboxes on the specified server will be scanned by
  the Calendar Repair Assistant. Calendars that have inconsistencies will be
  flagged and repaired according to the interval specified by
  the CalendarRepairWorkCycleCheckpoint parameter.
- **CalendarRepairWorkCycleCheckpoint**: The CalendarRepairWorkCycleCheckpoint
  parameter specifies the time span at which all mailboxes will be identified
  as needing work completed on them.
- **DomainController**: The DomainController parameter specifies the fully
  qualified domain name (FQDN) of the domain controller that writes
  this configuration change to Active Directory.
- **DatabaseCopyActivationDisabledAndMoveNow**: The DatabaseCopyActivationDisabledAndMoveNow
  parameter specifies whether to prevent databases from being mounted on this
  Mailbox server if there are other healthy copies of the databases on other
  Mailbox servers. It will also immediately move any mounted databases on
  the server to other servers if copies exist and are healthy.
- **DatabaseCopyAutoActivationPolicy**: The DatabaseCopyAutoActivationPolicy parameter
  specifies the type of automatic activation available for mailbox database copies
  on the specified Mailbox server. Valid values are Blocked, IntrasiteOnly, and Unrestricted.
- **FolderLogForManagedFoldersEnabled**: The FolderLogForManagedFoldersEnabled
  parameter specifies whether the folder log for managed folders is enabled for
  messages that were moved to managed folders.
- **ForceGroupMetricsGeneration**: The ForceGroupMetricsGeneration parameter
  specifies that group metrics information must be generated on the Mailbox server
  regardless of whether that server generates an offline address book (OAB).
  By default, group metrics are generated only on servers that generate OABs.
  Group metrics information is used by MailTips to inform senders about how
  many recipients their messages will be sent to.
  You need to use this parameter if your organization doesn't generate OABs and
  you want the group metrics data to be available.
- **IsExcludedFromProvisioning**: The IsExcludedFromProvisioning parameter specifies
  that the Mailbox server isn't considered by the OAB provisioning load balancer.
  If the IsExcludedFromProvisioning parameter is set to \$true, the server won't
  be used for provisioning a new OAB or for moving existing OABs.
- **JournalingLogForManagedFoldersEnabled**: The JournalingLogForManagedFoldersEnabled
  parameter specifies whether the log for managed folders is enabled for journaling.
  The two possible values for this parameter are $true or $false.
  If you specify \$true, information about messages that were journaled is logged.
  The logs are located at the location you specify with
  the LogPathForManagedFolders parameter.
- **Locale**: The Locale parameter specifies the locale. A locale is a collection
  of language-related user preferences such as writing system, calendar,
  and date format.
- **LogDirectorySizeLimitForManagedFolders**: The LogDirectorySizeLimitForManagedFolders
  parameter specifies the size limit for all managed folder log files from
  a single message database. After the limit is reached for a set of
  managed folder log files from a message database, the oldest files are deleted
  to make space for new files.
- **LogFileAgeLimitForManagedFolders**: The LogFileAgeLimitForManagedFolders parameter
  specifies how long to retain managed folder logs.
  Log files that exceed the maximum retention period are deleted.
- **LogFileSizeLimitForManagedFolders**: The LogFileSizeLimitForManagedFolders
  parameter specifies the maximum size for each managed folder log file.
  When the log file size limit is reached, a new log file is created.
- **LogPathForManagedFolders**: The LogPathForManagedFolders parameter specifies
  the path to the directory that stores the managed folder log files.
- **MailboxProcessorWorkCycle**: The MailboxProcessorWorkCycle parameter specifies
  how often to scan for locked mailboxes.
- **ManagedFolderAssistantSchedule**: The ManagedFolderAssistantSchedule parameter
  specifies the intervals each week during which the Managed Folder Assistant applies
  messaging records management (MRM) settings to managed folders. The format is StartDay.Time-EndDay.
- **ManagedFolderWorkCycle**: The ManagedFolderWorkCycle parameter specifies
  the time span in which all mailboxes on the specified server will be processed
  by the Managed Folder Assistant. The Managed Folder Assistant applies retention
  policies according to the ManagedFolderWorkCycleCheckpoint interval.
- **ManagedFolderWorkCycleCheckpoint**: The ManagedFolderWorkCycleCheckpoint
  parameter specifies the time span at which to refresh the list of mailboxes so
  that new mailboxes that have been created or moved will be part of the work queue.
  Also, as mailboxes are prioritized, existing mailboxes that haven't been
  successfully processed for a long time will be placed higher in the queue and
  will have a greater chance of being processed again in the same work cycle.
- **MAPIEncryptionRequired**: The MAPIEncryptionRequired parameter specifies whether
  Exchange blocks MAPI clients that don't use encrypted remote procedure calls (RPCs).
- **MaximumActiveDatabases**: The MaximumActiveDatabases parameter specifies
  the number of databases that can be mounted on this Mailbox server.
  This parameter accepts numeric values.
- **MaximumPreferredActiveDatabases**: The MaximumPreferredActiveDatabases
  parameter specifies a preferred maximum number of databases
  that a server should have.
  This value is different from the actual maximum, which is configured using
  the MaximumActiveDatabases parameter.
  The value of MaximumPreferredActiveDatabases is only honored during best copy
  and server selection, database and server switchovers,
  and when rebalancing the DAG.
- **OABGeneratorWorkCycle**: The OABGeneratorWorkCycle parameter specifies the
  time span in which the OAB generation on the specified server will be processed.
- **OABGeneratorWorkCycleCheckpoint**: The OABGeneratorWorkCycleCheckpoint parameter
  specifies the time span at which to run OAB generation.
- **PublicFolderWorkCycle**: The PublicFolderWorkCycle parameter is used by the
  public folder assistant to determine how often the mailboxes in
  a database are processed by the assistant.
- **PublicFolderWorkCycleCheckpoint**: The PublicFolderWorkCycleCheckpoint determines
  how often the mailbox list for a database is evaluated.
  The processing speed is also calculated.
- **RetentionLogForManagedFoldersEnabled**: The RetentionLogForManagedFoldersEnabled
  parameter specifies whether the Managed Folder Assistant logs information about
  messages that have reached their retention limits.
- **SharingPolicySchedule**: The SharingPolicySchedule parameter specifies
  the intervals each week during which the sharing policy runs.
  The Sharing Policy Assistant checks permissions on shared calendar items
  and contact folders in users' mailboxes against the assigned sharing policy.
  The assistant lowers or removes permissions according to the policy.
  The format is StartDay.Time-EndDay.Time.
- **SharingPolicyWorkCycle**: The SharingPolicyWorkCycle parameter specifies
  the time span in which all mailboxes on the specified server will be scanned by
  the Sharing Policy Assistant. The Sharing Policy Assistant scans all mailboxes
  and enables or disables sharing polices according to the interval specified by
  the SharingPolicyWorkCycle.
- **SharingPolicyWorkCycleCheckpoint**: The SharingPolicyWorkCycleCheckpoint parameter
  specifies the time span at which to refresh the list of mailboxes so that new mailboxes
  that have been created or moved will be part of the work queue. Also, as mailboxes
  are prioritized, existing mailboxes that haven't been successfully processed
  for a long time will be placed higher in the queue and will have a greater chance
  of being processed again in the same work cycle.
- **SharingSyncWorkCycle**: The SharingSyncWorkCycle parameter specifies
  the time span in which all mailboxes on the specified server will be synced to
  the cloud-based service by the Sharing Sync Assistant. Mailboxes that require
  syncing will be synced according to the interval specified by
  the SharingSyncWorkCycleCheckpoint parameter.
- **SharingSyncWorkCycleCheckpoint**: The SharingSyncWorkCycleCheckpoint parameter
  specifies the time span at which to refresh the list of mailboxes so that new mailboxes
  that have been created or moved will be part of the work queue. Also, as mailboxes
  are prioritized, existing mailboxes that haven't been successfully processed for
  a long time will be placed higher in the queue and will have a greater chance of
  being processed again in the same work cycle.
- **SiteMailboxWorkCycle**: The SiteMailboxWorkCycle parameter specifies
  the time span in which the site mailbox information on the specified server
  will be processed.
- **SiteMailboxWorkCycleCheckpoint**: The SiteMailboxWorkCycleCheckpoint parameter
  specifies the time span at which to refresh the site mailbox workcycle.
- **SubjectLogForManagedFoldersEnabled**: The SubjectLogForManagedFoldersEnabled
  parameter specifies whether the subject of messages is displayed in
  managed folder logs.
- **TopNWorkCycle**: The TopNWorkCycle parameter specifies the time span in which
  all mailboxes that have Unified Messaging on the specified server will be scanned
  by the TopN Words Assistant. The TopN Words Assistant scans voice mail for
  the most frequently used words to aid in transcription.
- **TopNWorkCycleCheckpoint**: The TopNWorkCycleCheckpoint parameter specifies
  the time span at which to refresh the list of mailboxes so that new mailboxes
  that have been created or moved will be part of the work queue. Also, as mailboxes
  are prioritized, existing mailboxes that haven't been successfully processed
  for a long time will be placed higher in the queue and will have a greater chance
  of being processed again in the same work cycle.
- **UMReportingWorkCycle**: The UMReportingWorkCycle parameter specifies
  the time span in which the arbitration mailbox named SystemMailbox{e0dc1c29-89c3-4034-b678-e6c29d823ed9}
  on the specified server will be scanned by the Unified Messaging Reporting Assistant.
  The Unified Messaging Reporting Assistant updates the Call Statistics reports by
  reading Unified Messaging call data records for an organization on a regular basis.
- **UMReportingWorkCycleCheckpoint**: The UMReportingWorkCycleCheckpoint parameter
  specifies the time span at which the arbitration mailbox named SystemMailbox{e0dc1c29-89c3-4034-b678-e6c29d823ed9}
  will be marked by processing.
- **WacDiscoveryEndpoint**: The WacDiscoveryEndpoint parameter specifies
  the Office Online Server endpoint to use. Exchange 2016 only.

#### Common Issues

The parameter Locale doesn't work.

### xExchMailboxTransportService

**xExchMailboxTransportService** configures the Mailbox Transport service
settings on Mailbox servers using Set-MailboxTransportService.

Where no description is listed, properties correspond directly to
[Set-MailboxTransportService](https://docs.microsoft.com/en-us/powershell/module/exchange/mail-flow/set-mailboxtransportservice)
parameters.

- **Identity**: Hostname of the server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to restart service to make changes active
- **ConnectivityLogEnabled**
- **ConnectivityLogMaxAge**
- **ConnectivityLogMaxDirectorySize**
- **ConnectivityLogMaxFileSize**
- **ConnectivityLogPath**
- **ContentConversionTracingEnabled**
- **MaxConcurrentMailboxDeliveries**
- **MaxConcurrentMailboxSubmissions**
- **PipelineTracingEnabled**
- **PipelineTracingPath**
- **PipelineTracingSenderAddress**
- **ReceiveProtocolLogMaxAge**
- **ReceiveProtocolLogMaxDirectorySize**
- **ReceiveProtocolLogMaxFileSize**
- **ReceiveProtocolLogPath**
- **SendProtocolLogMaxAge**
- **SendProtocolLogMaxDirectorySize**
- **SendProtocolLogMaxFileSize**
- **SendProtocolLogPath**

#### Common Issues

To set some settings to NULL you need to set the value to '' instead of using \$null.
The following settings are affected: PipelineTracingSenderAddress

### xExchMaintenanceMode

**xExchMaintenanceMode** is used for putting a Database Availability Group member
in and out of maintenance mode. Only works with servers that have both
the Client Access and Mailbox Server roles.

- **Enabled**: Whether the server should be put into Maintenance Mode.
  When Enabled is set to True, the server will be put in Maintenance Mode.
  If False, the server will be taken out of Maintenance Mode.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AdditionalComponentsToActivate**: When taking a server out of Maintenance Mode,
  the following components will be set to Active by default: ServerWideOffline,
  UMCallRouter, HighAvailability, Monitoring, RecoveryActionsEnabled.
  This parameter specifies an additional list of components to set to Active.
- **DomainController**: The DomainController parameter specifies the fully
  qualified domain name (FQDN) of the domain controller that writes this
  configuration change to Active Directory.
- **MountDialOverride**: Used when moving databases back to the server after
  taking the server out of maintenance mode. The MountDialOverride parameter
  is used to override the auto database mount dial (AutoDatabaseMountDial)
  setting for the target server and specify an alternate setting. Defaults to
  None.
- **MovePreferredDatabasesBack**: Whether to move back databases with an
  Activation Preference of one for this server after taking the server out of
  Maintenance Mode. Defaults to False.
- **SetInactiveComponentsFromAnyRequesterToActive**: Whether components that were
  set to Inactive by outside Requesters should also be set to Active
  when exiting Maintenance Mode. Defaults to False.
- **SkipActiveCopyChecks**: Used when moving databases back to the server after
  taking the server out of maintenance mode. The SkipActiveCopyChecks switch
  specifies whether to skip checking the current active copy to see if it's
  currently a seeding source for any passive databases. Defaults to False.
- **SkipAllChecks**: Exchange 2016 Only. Used when moving databases back to the
  server after taking the server out of maintenance mode. The SkipAllChecks
  switch specifies whether to skip all checks. This switch is equivalent to
  specifying all of the individual skip parameters that are available on this
  cmdlet. Defaults to False.
- **SkipClientExperienceChecks**: Used when moving databases back to the server
  after taking the server out of maintenance mode. The
  SkipClientExperienceChecks switch specifies whether to skip the search
  catalog (content index) state check to see if the search catalog is healthy
  and up to date. Defaults to False.
- **SkipCpuChecks**: Exchange 2016 Only. Used when moving databases back to the
  server after taking the server out of maintenance mode. The SkipCpuChecks
  switch specifies whether to skip the high CPU utilization checks. Defaults to
  False.
- **SkipHealthChecks**: Used when moving databases back to the server after
  taking the server out of maintenance mode. The SkipHealthChecks switch
  specifies whether to bypass passive copy health checks. Defaults to False.
- **SkipLagChecks**: Used when moving databases back to the server after taking
  the server out of maintenance mode. The SkipLagChecks switch specifies
  whether to allow a copy to be activated that has replay and copy queues
  outside of the configured criteria. Defaults to False.
- **SkipMaximumActiveDatabasesChecks**: Used when moving databases back to the
  server after taking the server out of maintenance mode. The
  SkipMaximumActiveDatabasesChecks switch specifies whether to skip checking
  the value of MaximumPreferredActiveDatabases during the best copy and server
  selection (BCSS) process. Defaults to False.
- **SkipMoveSuppressionChecks**: Exchange 2016 Only. Used when moving databases
  back to the server after taking the server out of maintenance mode. The
  SkipMoveSuppressionChecks switch specifies whether to skip the move
  suppression checks. Defaults to False.
- **UpgradedServerVersion**: Optional string to specify what the server version
  will be after applying a Cumulative Update. If the server is already at this version,
  requests to put the server in Maintenance Mode will be ignored.
  Version should be in the format ##.#.####.#, as in 15.0.1104.5.

#### Maintenance Mode Procedures

**xExchMaintenanceMode** performs the following steps when entering or
exiting Maintenance Mode

#### Entering Maintenance Mode

- Set DatabaseCopyAutoActivationPolicy to Blocked
- Set UMCallrouter to Draining
- Execute TransportMaintenance.psm1 -> Start-TransportMaintenance
  - Pause MSExchangeTransport service
  - Wait for queues to drain
  - Redirect remaining messages
  - Set HubTransport component to Inactive
  - Resume MSExchangeTransport
- Wait up to 5 minutes for active UM calls to finish
- Run StartDagServerMaintenance.psm1
  - Set HighAvailability component to Inactive
  - Suspend Cluster Node
  - Move active databases: Move-ActiveMailboxDatabase -Server SERVER
  - Move the Primary Active Manager role
- Set ServerWideOffline component to Inactive

#### Exiting Maintenance Mode

- Set ServerWideOffline component to Active
- Set UMCallrouter to Active
- Run StopDagServerMaintenance.ps1
  - Resume Cluster Node
  - Set HubTransport component to Active
  - Set DatabaseCopyAutoActivationPolicy to Unrestricted
- Execute TransportMaintenance.psm1 -> Stop-TransportMaintenance
  - Set HubTransport component to Active
  - Restart MSExchangeTransport service
- Set Monitoring component to Active
- Set RecoveryActionsEnabled component to Active
- (OPTIONAL) Set each in an admin provided list of components to Active
- (OPTIONAL) For each of the above components, set to Active for ANY requester
  (this addresses the case where multiple requesters have set a component to Inactive,
  like HealthApi and Maintenance)
- (OPTIONAL) Move back all databases with an Activation Preference of 1

### xExchMapiVirtualDirectory

**xExchMapiVirtualDirectory** is used to configure properties on a MAPI
Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-MapiVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-mapivirtualdirectory)
parameters.

- **Identity**: The Identity of the MAPI Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to recycle the app pool
  after making changes.
  Defaults to \$false.
- **DomainController**
- **ExternalUrl**
- **IISAuthenticationMethods**
- **InternalUrl**

### xExchOabVirtualDirectory

**xExchOabVirtualDirectory** is used to configure properties on an Offline
Address Book Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-OabVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/email-addresses-and-address-books/set-oabvirtualdirectory)
parameters.

- **Identity**: The Identity of the OAB Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **OABsToDistribute**: An array of names of Offline Address Books that this
  virtual directory should be added as a distribution point for.
  Should not be used for any OAB where 'Set-OfflineAddressBook -GlobalWebDistributionEnabled'
  is being used.
- **AllowServiceRestart**: Whether it is okay to recycle the app pool
  after making changes.
  Defaults to \$false.
- **BasicAuthentication**
- **DomainController**
- **ExtendedProtectionFlags**
- **ExtendedProtectionSPNList**
- **ExtendedProtectionTokenChecking**
- **ExternalUrl**
- **InternalUrl**
- **OAuthAuthentication**
- **PollInterval**
- **RequireSSL**
- **WindowsAuthentication**

### xExchOutlookAnywhere

**xExchOutlookAnywhere** is used to configure Outlook Anywhere
properties for an Exchange Server.

Where no description is listed, properties correspond directly to
[Set-OutlookAnywhere](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-outlookanywhere)
parameters.

- **Identity**: The Identity of the Outlook Anywhere Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is okay to recycle the app pool
  after making changes.
  Defaults to \$false.
- **DomainController**
- **ExternalClientsRequireSsl**
- **ExtendedProtectionFlags**
- **ExtendedProtectionSPNList**
- **ExtendedProtectionTokenChecking**
- **ExternalClientAuthenticationMethod**
- **ExternalHostname**
- **IISAuthenticationMethods**
- **InternalClientsRequireSsl**
- **InternalHostname**
- **SSLOffloading**

### xExchOwaVirtualDirectory

**xExchOwaVirtualDirectory** is used to configure properties on an Outlook
on the Web Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-OwaVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-owavirtualdirectory)
parameters.

- **Identity**: The Identity of the OWA Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to recycle the app pool
  after making changes.
  Defaults to \$false.
- **ActionForUnknownFileAndMIMETypes**
- **AdfsAuthentication**
- **BasicAuthentication**
- **ChangePasswordEnabled**
- **DigestAuthentication**
- **DomainController**
- **ExternalAuthenticationMethods**
- **ExternalUrl**
- **FormsAuthentication**
- **GzipLevel**
- **InternalUrl**
- **InstantMessagingEnabled**
- **InstantMessagingCertificateThumbprint**
- **InstantMessagingServerName**
- **InstantMessagingType**
- **LogonPagePublicPrivateSelectionEnabled**
- **LogonPageLightSelectionEnabled**
- **UNCAccessOnPublicComputersEnabled**
- **UNCAccessOnPrivateComputersEnabled**
- **WindowsAuthentication**
- **WSSAccessOnPublicComputersEnabled**
- **WSSAccessOnPrivateComputersEnabled**
- **LogonFormat**
- **DefaultDomain**
- **SetPhotoEnabled**

### xExchPopSettings

**xExchPopSettings** configures POP settings using Set-PopSettings.

Most properties correspond directly to
[Set-PopSettings](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access/set-popsettings)
parameters.

- **Server**: Hostname of the POP server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to restart the POP services
  after making changes.
  Defaults to \$false.
- **DomainController**: Optional Domain Controller to connect to.
- **ExternalConnectionSettings**: Specifies the host name, port, and encryption
  type that Exchange uses when POP clients connect to their email from the outside.
- **LoginType**: The LoginType to be used for POP
- **X509CertificateName**: Specifies the host name in the SSL certificate
  from the Associated Subject field.

### xExchPowerShellVirtualDirectory

**xExchPowerShellVirtualDirectory** is used to configure properties on a
PowerShell Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-PowerShellVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-powershellvirtualdirectory)
parameters.

- **Identity**: The Identity of the PowerShell Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to recycle the app pool
  after making changes.
  Defaults to \$false.
- **BasicAuthentication**
- **CertificateAuthentication**
- **DomainController**
- **ExternalUrl**
- **InternalUrl**
- **WindowsAuthentication**

### xExchReceiveConnector

**xExchReceiveConnector** is used to create, remove, or change properties on a
Receive Connector.

Where no description is listed, properties correspond directly to
[Set-ReceiveConnector](https://docs.microsoft.com/en-us/powershell/module/exchange/mail-flow/set-receiveconnector)
parameters.

- **Identity**: Identity of the Receive Connector.
  Needs to be in the format 'SERVERNAME\CONNECTORNAME' (no quotes).
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **Ensure**: Whether the Receive Connector should exist or not:{Present | Absent}
- **ExtendedRightAllowEntries**: additional AD permissions, which should
  be add to the connector.
  Can have multiple entries. Example:
  @{"NT AUTHORITY\ANONYMOUS LOGON"="Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-XShadow";
  "Domain Users"="Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-Bypass-Anti-Spam"}
- **ExtendedRightDenyEntries**: Similar as ExtendedRightAllowEntries, but to
  make sure the defined permission is not set
- **AdvertiseClientSettings**: Specifies whether the SMTP server name,port number,
  and authentication settings for the Receive connector are displayed to users in
  the options of Outlook on the web.
- **AuthMechanism**: Specifies the advertised and accepted authentication
  mechanisms for the Receive connector.
- **AuthTarpitInterval**: Specifies the period of time to delay responses to
  failed authentication attempts from remote servers.
- **Banner**: Specifies a custom SMTP 220 banner that's displayed to remote
  messaging servers.
- **BareLinefeedRejectionEnabled**: Specifies whether this Receive connector
  rejects messages that contain line feed
- **BinaryMimeEnabled**: Specifies whether the BINARYMIME Extended SMTP extension
  is enabled or disabled.
- **Bindings**: Specifies the local IP address and TCP port number that's used
  by the Receive connector.
- **ChunkingEnabled**: Specifies whether the CHUNKING Extended SMTP extension
  is enabled or disabled.
- **Comment**: Specifies an optional comment.
- **ConnectionInactivityTimeout**: Specifies the maximum amount of idle time
  before a connection to the Receive connector is closed.
- **ConnectionTimeout**: Specifies the maximum time that the connection to the
  Receive connector can remain open
- **DefaultDomain**: Specifies the default accepted domain to use for the
  Exchange organization.
- **DeliveryStatusNotificationEnabled**: Specifies whether the DSN
- **DomainController**: Specifies the domain controller that's used by this
  cmdlet to read data from or write data to Active Directory.
- **DomainSecureEnabled**: Specifies whether to enable or disable mutual
  Transport Layer Security
- **EightBitMimeEnabled**: Specifies whether the 8BITMIME Extended SMTP extension
  is enabled or disabled.
- **EnableAuthGSSAPI**: enables or disables Kerberos when Integrated Windows
  authentication is available on the Receive connector.
- **Enabled**: Specifies whether to enable or disable the Receive connector.
- **EnhancedStatusCodesEnabled**: Specifies whether the ENHANCEDSTATUSCODES
  Extended SMTP extension is enabled or disabled.
- **ExtendedRightAllowEntries**: Additional allow permissions.
- **ExtendedRightDenyEntries**: Additional denz permissions.
- **ExtendedProtectionPolicy**: Specifies how you want to use Extended Protection
  for Authentication on the Receive connector.
- **Fqdn**: Specifies the destination FQDN that's shown to connected messaging servers.
- **LongAddressesEnabled**: Specifies whether the Receive connector accepts long
  X.400 email addresses.
- **MaxAcknowledgementDelay**: Specifies the period the transport server delays
  acknowledgement when receiving messages from a host that doesn't support shadow redundancy.
- **MaxHeaderSize**: Specifies the maximum size of the SMTP message header before
  the Receive connector closes the connection.
- **MaxHopCount**: Specifies the maximum number of hops that a message can take
  before the message is rejected by the Receive connector.
- **MaxInboundConnection**: Specifies the maximum number of inbound connections
  that this Receive connector serves at the same time.
- **MaxInboundConnectionPercentagePerSource**: Specifies the maximum number of
  connections that this Receive connector serves at the same time from a single IP
  address.
- **MaxInboundConnectionPerSource**: Specifies the maximum number of connections
  that a Receive connector serves at the same time from a single IP address
- **MaxLocalHopCount**: Specifies the maximum number of local hops that a message
  can take before the message is rejected by the Receive connector.
- **MaxLogonFailures**: pecifies the number of logon failures that the Receive
  connector retries before it closes the connection.
- **MaxMessageSize**: Specifies the maximum size of a message that's allowed
  through the Receive connector.
- **MaxProtocolErrors**: Specifies the maximum number of SMTP protocol errors
  that the Receive connector accepts before closing the connection.
- **MaxRecipientsPerMessage**: Specifies the maximum number of recipients per
  message that the Receive connector accepts before closing the connection.
- **MessageRateLimit**: Specifies the maximum number of messages that can be
  sent by a single client IP address per minute.
- **MessageRateSource**: Specifies how the message submission rate is calculated.
- **OrarEnabled**: enables or disables Originator Requested Alternate Recipient
- **PermissionGroups**: Specifies the well
- **PipeliningEnabled**: Specifies whether the PIPELINING Extended SMTP
  extension is enabled or disabled.
- **ProtocolLoggingLevel**: pecifies whether to enable or disable protocol logging.
- **RemoteIPRanges**: Specifies the remote IP addresses that the Receive
  connector accepts messages from.
- **RequireEHLODomain**: Specifies whether the client must provide a domain name
  in the EHLO handshake after the SMTP connection is established.
- **RequireTLS**: Specifies whether to require TLS transmission for inbound messages.
- **SizeEnabled**: Specifies how the SIZE Extended SMTP extension is used on the
  Receive connector.
- **SuppressXAnonymousTls**: Specifies whether the X
- **TarpitInterval**: Specifies the period of time to delay an SMTP response to
  a remote server that may be abusing the connection.
- **TlsCertificateName**: Specifies the X.509 certificate to use for TLS encryption.
- **TlsDomainCapabilities**: Specifies the capabilities that the Receive connector
  makes available to specific hosts outside of the organization.
- **TransportRole**: Specifies the transport service on the Mailbox server where
  the Receive connector is created.
- **Usage**: Specifies the default permission groups and authentication methods
  that are assigned to the Receive connector.

### xExchRemoteDomain

**xExchRemoteDomain** adds a remote domain

- **DomainName** Specifies the SMTP domain that you want to establish as a
  remote domain.
- **Credential** Credentials used to establish a remote PowerShell session to Exchange.
- **AllowedOOFType** The AllowedOOFType parameter specifies the type of automatic
  replies or out-of-office (also known as OOF) notifications than can be sent to
  recipients in the remote domain.
- **AutoForwardEnabled** The AutoForwardEnabled parameter specifies whether to
  allow messages that are auto-forwarded by client email programs in your organization.
- **AutoReplyEnabled** The AutoReplyEnabled parameter specifies whether to allow
  messages that are automatic replies from client email programs in your organization.
- **ContentType** The ContentType parameter specifies the outbound message content
  type and formatting.
- **DeliveryReportEnabled** The DeliveryReportEnabled parameter specifies whether
  to allow delivery reports from client software in your organization to recipients
  in the remote domain.
- **DisplaySenderName** The DisplaySenderName parameter specifies whether to
  show the sender's Display Name in the From email address for messages sent to
  recipients in the remote domain.
- **IsInternal** The IsInternal parameter specifies whether the recipients in the
  remote domain are considered to be internal recipients.
- **MeetingForwardNotificationEnabled** The MeetingForwardNotificationEnabled
  parameter specifies whether to enable meeting forward notifications for
  recipients in the remote domain.
- **Name** The Name parameter specifies a unique name for the remote domain object.
- **NDREnabled** The NDREnabled parameter specifies whether to allow non-delivery
  reports (also known NDRs or bounce messages) from your organization to recipients
  in the remote domain.
- **NonMimeCharacterSet** The NonMimeCharacterSet parameter specifies a character
  set for plain text messages without defined character sets that are sent from
  your organization to recipients in the remote domain.
- **UseSimpleDisplayName** The UseSimpleDisplayName parameter specifies whether
  the sender's simple display name is used for the From email address in
  messages sent to recipients in the remote domain.

### xExchSendConnector

- **Name** Specifies a descriptive name for the connector.
- **Credential** Credentials used to establish a remote PowerShell session to Exchange.
- **Ensure** Whether the connector should be present or not.
- **AddressSpaces** Specifies the domain names to which the Send connector routes
  mail.
- **AuthenticationCredential** Specifies the username and password that's
  required to use the connector.
- **Comment** Specifies an optional comment.
- **ConnectionInactivityTimeout** Specifies the maximum time an idle connection
  can remain open.
- **ConnectorType** Specifies whether the connector is used in hybrid deployments
  to send messages to Office 365.
- **DNSRoutingEnabled** Specifies whether the Send connector uses Domain Name System
- **DomainController** Specifies the domain controller that's used by this cmdlet
  to read data from or write data to ActivDirectory.
- **DomainSecureEnabled** Enables mutual Transport Layer Security
- **Enabled** Specifies whether to enable the Send connector to process email messages.
- **ErrorPolicies** Specifies how communication errors are treated.
- **ExtendedRightAllowEntries** Additional allow permissions.
- **ExtendedRightDenyEntries** Additional deny permissions.
- **ForceHELO** Specifies whether HELO is sent instead of the default EHLO.
- **FrontendProxyEnabled** Routes outbound messages through the CAS server
- **Fqdn** Specifies the FQDN used as the source server.
- **IgnoreSTARTTLS** Specifies whether to ignore the StartTLS option offered by
  a remote sending server.
- **IsCoexistenceConnector** Specifies whether this Send connector is used for
  secure mail flow between your on
- **IsScopedConnector** Specifies the availability of the connector to other
  Mailbox servers with the Transport service.
- **LinkedReceiveConnector** Specifies whether to force all messages received
  by the specified Receive connector out through thi Send connector.
- **MaxMessageSize** Specifies the maximum size of a message that can pass
  through a connector.
- **Port** Specifies the port number for smart host forwarding.
- **ProtocolLoggingLevel** Specifies whether to enable protocol logging.
- **RequireTLS** Specifies whether all messages sent through this connector must
  be transmitted using TLS.
- **SmartHostAuthMechanism** Specifies the smart host authentication mechanism
  to use for authentication.
- **SmartHosts** Specifies the smart hosts the Send connector uses to route mail.
- **SmtpMaxMessagesPerConnection** Specifies the maximum number of messages the
  server can send per connection.
- **SourceIPAddress** Specifies the local IP address to use as the endpoint for
  an SMTP connection.
- **SourceTransportServers** Specifies the names of the Mailbox servers that can
  use this Send connector.
- **TlsAuthLevel** Specifies the TLS authentication level that is used for
  outbound TLS connections.
- **TlsDomain** Specifies the domain name that the Send connector uses to verify
  the FQDN of the target certificate.
- **UseExternalDNSServersEnabled** Specifies whether the connector uses the
  DNS list specified by the ExternalDNSServerparameter of the Set
- **TlsCertificateName** Specifies the X.509 certificate to use for TLS encryption.
- **Usage** Specifies the default permissions and authentication methods
  assigned to the Send connector.

### xExchTransportService

**xExchTransportService** configures the Transport service settings on Mailbox
servers or Edge Transport servers using Set-TransportService.

Where no description is listed, properties correspond directly to
[Set-TransportService](https://docs.microsoft.com/en-us/powershell/module/exchange/mail-flow/Set-TransportService)
parameters.

- **Identity**: Hostname of the server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to restart service to make changes active
- **ActiveUserStatisticsLogMaxAge**
- **ActiveUserStatisticsLogMaxDirectorySize**
- **ActiveUserStatisticsLogMaxFileSize**
- **ActiveUserStatisticsLogPath**
- **AgentLogEnabled**
- **AgentLogMaxAge**
- **AgentLogMaxDirectorySize**
- **AgentLogMaxFileSize**
- **AgentLogPath**
- **AntispamAgentsEnabled**
- **ConnectivityLogEnabled**
- **ConnectivityLogMaxAge**
- **ConnectivityLogMaxDirectorySize**
- **ConnectivityLogMaxFileSize**
- **ConnectivityLogPath**
- **ContentConversionTracingEnabled**
- **DelayNotificationTimeout**
- **DnsLogEnabled**
- **DnsLogMaxAge**
- **DnsLogMaxDirectorySize**
- **DnsLogMaxFileSize**
- **DnsLogPath**
- **ExternalDNSAdapterEnabled**
- **ExternalDNSAdapterGuid**
- **ExternalDNSProtocolOption**
- **ExternalDNSServers**
- **ExternalIPAddress**
- **InternalDNSAdapterEnabled**
- **InternalDNSAdapterGuid**
- **InternalDNSProtocolOption**
- **InternalDNSServers**
- **IntraOrgConnectorProtocolLoggingLevel**
- **IntraOrgConnectorSmtpMaxMessagesPerConnection**
- **IrmLogEnabled**
- **IrmLogMaxAge**
- **IrmLogMaxDirectorySize**
- **IrmLogMaxFileSize**
- **IrmLogPath**
- **MaxConcurrentMailboxDeliveries**
- **MaxConcurrentMailboxSubmissions**
- **MaxConnectionRatePerMinute**
- **MaxOutboundConnections**
- **MaxPerDomainOutboundConnections**
- **MessageExpirationTimeout**
- **MessageRetryInterval**
- **MessageTrackingLogEnabled**
- **MessageTrackingLogMaxAge**
- **MessageTrackingLogMaxDirectorySize**
- **MessageTrackingLogMaxFileSize**
- **MessageTrackingLogPath**
- **MessageTrackingLogSubjectLoggingEnabled**
- **OutboundConnectionFailureRetryInterval**
- **PickupDirectoryMaxHeaderSize**
- **PickupDirectoryMaxMessagesPerMinute**
- **PickupDirectoryMaxRecipientsPerMessage**
- **PickupDirectoryPath**
- **PipelineTracingEnabled**
- **PipelineTracingPath**
- **PipelineTracingSenderAddress**
- **PoisonMessageDetectionEnabled**
- **PoisonThreshold**
- **QueueLogMaxAge**
- **QueueLogMaxDirectorySize**
- **QueueLogMaxFileSize**
- **QueueLogPath**
- **QueueMaxIdleTime**
- **ReceiveProtocolLogMaxAge**
- **ReceiveProtocolLogMaxDirectorySize**
- **ReceiveProtocolLogMaxFileSize**
- **ReceiveProtocolLogPath**
- **RecipientValidationCacheEnabled**
- **ReplayDirectoryPath**
- **RootDropDirectoryPath**
- **RoutingTableLogMaxAge**
- **RoutingTableLogMaxDirectorySize**
- **RoutingTableLogPath**
- **SendProtocolLogMaxAge**
- **SendProtocolLogMaxDirectorySize**
- **SendProtocolLogMaxFileSize**
- **SendProtocolLogPath**
- **ServerStatisticsLogMaxAge**
- **ServerStatisticsLogMaxDirectorySize**
- **ServerStatisticsLogMaxFileSize**
- **ServerStatisticsLogPath**
- **TransientFailureRetryCount**
- **TransientFailureRetryInterval**
- **UseDowngradedExchangeServerAuth**

#### Common Issues

To set some settings to NULL you need to set the value to '' instead of using \$null.
The following settings are affected:
ExternalDNSServers
ExternalIPAddress
InternalDNSServers
PipelineTracingSenderAddress

### xExchUMCallRouterSettings

**xExchUMCallRouterSettings** configures the UM Call Router service using
Set-UMCallRouterSettings. This resource is NOT supported with Exchange Server
2019 or higher.

Where no description is listed, properties correspond directly to
[Set-UMCallRouterSettings](https://docs.microsoft.com/en-us/powershell/module/exchange/unified-messaging/set-umcallroutersettings)
parameters.

- **Server**: Hostname of the UM server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **DialPlans**: Specifies all dial plans that the Unified Messaging service
  handles incoming calls for.
- **IPAddressFamily**: Specifies whether the UM IP gateway will use IPv4, IPv6,
  or both to communicate. {IPv4Only | IPv6Only | Any}
- **IPAddressFamilyConfigurable**: Specifies whether you're able to set the
  IPAddressFamily parameter to IPv6Only or Any.
- **MaxCallsAllowed**: Specifies the maximum number of concurrent voice calls
  that the Unified Messaging service allows.
- **SipTcpListeningPort**: Specifies the TCP port that's used by the Microsoft
  Exchange Unified Messaging Call Router service to receive incoming calls.
- **SipTlsListeningPort**: Specifies the Transport Layer Security (TLS) port
  that's used by the Microsoft Exchange Unified Messaging Call Router service to
  receive incoming calls.
- **UMStartupMode**: Specifies whether the Microsoft Exchange Unified Messaging
  Call Router service starts up in TCP, TLS, or Dual mode
- **DomainController**: Optional Domain Controller to connect to.

### xExchUMService

**xExchUMService** configures a UM server using Set-UMService. This resource is
NOT supported with Exchange Server 2019 or higher.

Where no description is listed, properties correspond directly to
[Set-UMService](https://docs.microsoft.com/en-us/powershell/module/exchange/unified-messaging/set-umservice)
parameters.

- **Identity**: Hostname of the UM server to configure.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **UMStartupMode**: Specifies whether the Microsoft Exchange Unified Messaging
  Call Router service starts up in TCP, TLS, or Dual mode
- **DialPlans**: Specifies all dial plans that the Unified Messaging service
  handles incoming calls for.
- **GrammarGenerationSchedule**: Specifies the Grammar Generation Schedule.
- **IPAddressFamily**: Specifies whether the UM IP gateway will use IPv4, IPv6,
  or both to communicate. {IPv4Only | IPv6Only | Any}
- **IPAddressFamilyConfigurable**: Specifies whether you're able to set the
  IPAddressFamily parameter to IPv6Only or Any.
- **IrmLogEnabled**: Specifies whether to enable logging of Information Rights
  Management (IRM) transactions. IRM logging is enabled by default.
- **IrmLogMaxAge**: Specifies the maximum age for the IRM log file. Log files
  that are older than the specified value are deleted.
- **IrmLogMaxDirectorySize**: Specifies the maximum size of all IRM logs in
  the connectivity log directory. When a directory reaches its maximum file
  size, the server deletes the oldest log files first.
- **IrmLogMaxFileSize**: Specifies the maximum size of each IRM log file.
  When a log file reaches its maximum file size, a new log file is created.
- **IrmLogPath**: Specifies the default IRM log directory location.
- **MaxCallsAllowed**: Specifies the maximum number of concurrent voice calls
  that the Unified Messaging service allows.
- **SIPAccessService**: Specifies the FQDN and TCP port of the nearest Skype
  for Business Server pool location for inbound and outbound calls from remote
  Skype for Business users located outside of the network.
- **DomainController**: Optional Domain Controller to connect to.

### xExchWaitForADPrep

**xExchWaitForADPrep** ensures that Active Directory has been prepared for
Exchange 2013, 2016, or 2019 using setup /PrepareSchema, /PrepareAD,
and /PrepareDomain. To find appropriate version values for the SchemaVersion,
OrganizationVersion, and DomainVersion parameters, consult the 'Exchange 2016
Active Directory versions' section of the article
[Prepare Active Directory and domains](https://docs.microsoft.com/en-us/Exchange/plan-and-deploy/prepare-ad-and-domains).

- **Identity**: Not actually used. Enter anything, as long as it's not null.
- **Credential**: Credentials used to perform Active Directory lookups against
  the Schema, Configuration, and Domain naming contexts.
- **SchemaVersion**: Specifies that the Active Directory schema should have been
  prepared using Exchange 2013, 2016, or 2019 'setup /PrepareSchema',
  and should be at the specified version.
- **OrganizationVersion**: Specifies that the Exchange Organization should have
  been prepared using Exchange 2013, 2016, or 2019 'setup
  /PrepareAD', and should be at the specified version.
- **DomainVersion**: Specifies that the domain containing the target
  Exchange 2013, 2016, or 2019 server was prepared using setup
  /PrepareAD, /PrepareDomain, or /PrepareAllDomains, and should be at the
  specified version.
- **ExchangeDomains**: The FQDN's of domains that should be checked for
  DomainVersion in addition to the domain that this Exchange server belongs to.
- **RetryIntervalSec**: How many seconds to wait between retries when checking
  whether AD has been prepped.
  Defaults to 60.
- **RetryCount**: How many retry attempts should be made to see if AD has been
  prepped before an exception is thrown.
  Defaults to 30.

### xExchWaitForDAG

**xExchWaitForDAG** is used by DAG members who are NOT maintaining the DAG
configuration. Intended to be used as a DependsOn property by
**xExchDatabaseAvailabilityGroupMember**. Throws an exception if the DAG still
does not exist after the specified retry count and interval. If this happens,
DSC configurations run in push mode will need to be re-executed.

- **Identity**: The name of the DAG to wait for.
- **Credential**: Credentials used to establish a remote PowerShell session to
  Exchange.
- **DomainController**: Optional Domain controller to use when running
  Get-DatabaseAvailabilityGroup.
- **WaitForComputerObject**: Whether DSC should also wait for the DAG Computer
  account object to be discovered. Defaults to False.
- **RetryIntervalSec**: How many seconds to wait between retries when checking
  whether the DAG exists. Defaults to 60.
- **RetryCount**: How many retry attempts should be made to find the DAG
  before an exception is thrown. Defaults to 5.

### xExchWaitForMailboxDatabase

**xExchWaitForMailboxDatabase** is used as a DependsOn property by
**xExchMailboxDatabaseCopy** to ensure that a Mailbox Database exists prior to
trying to add a copy. Throws an exception if the database still does not exist
after the specified retry count and interval. If this happens, DSC
configurations run in push mode will need to be re-executed.

- **Identity**: The name of the Mailbox Database.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **DomainController**: Domain controller to talk to when running Get-MailboxDatabase.
- **RetryIntervalSec**: How many seconds to wait between retries when checking
  whether the database exists.
  Defaults to 60.
- **RetryCount**: Mount many retry attempts should be made to find the database
  before an exception is thrown.
  Defaults to 5.

### xExchWebServicesVirtualDirectory

**xExchWebServicesVirtualDirectory** is used to configure properties on an
Exchange Web Services Virtual Directory.

Where no description is listed, properties correspond directly to
[Set-WebServicesVirtualDirectory](https://docs.microsoft.com/en-us/powershell/module/exchange/client-access-servers/set-webservicesvirtualdirectory)
parameters.

- **Identity**: The Identity of the EWS Virtual Directory.
- **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
- **AllowServiceRestart**: Whether it is OK to recycle the app pool
  after making changes. Defaults to \$false.
- **BasicAuthentication**
- **CertificateAuthentication**
- **DigestAuthentication**
- **DomainController**
- **ExtendedProtectionFlags**
- **ExtendedProtectionSPNList**
- **ExtendedProtectionTokenChecking**
- **ExternalUrl**
- **GzipLevel**
- **InternalNLBBypassUrl**
- **InternalUrl**
- **MRSProxyEnabled**
- **OAuthAuthentication**
- **WindowsAuthentication**
- **WSSecurityAuthentication**

#### Common Issues

CertificateAuthentication: This parameter affects the
[Servername]/ews/management/ virtual directory.
It doesn't affect the [Servername]/ews/ virtual directory.

## Examples

### ConfigureAutoMountPoint-FromCalculator

Configures ExchangeDatabase and ExchangeVolume mount points automatically using
the **xExchAutoMountPoint** resource.
Shows how to feed the .CSV files from the Server Role Requirements Calculator
into the resource.
The example code for ConfigureAutoMountPoint-FromCalculator is located in
"ConfigureAutoMountPoints-FromCalculator.ps1" in the module folder under ...\xExchange\Examples\ConfigureAutoMountPoint-FromCalculator.

### ConfigureAutoMountPoint-Manual

Configures ExchangeDatabase and ExchangeVolume mount points automatically using
the **xExchAutoMountPoint** resource.
Configures disk map manually.
The example code for ConfigureAutoMountPoint-Manual is located in
"ConfigureAutoMountPoints-Manual.ps1" in the module folder under ...\xExchange\Examples\ConfigureAutoMountPoints-Manual.

### ConfigureDatabases-FromCalculator

Configures primary databases and database copies using the **xExchMailboxDatabase**,
**xExchMailboxDatabaseCopy**, and **xExchWaitForMailboxDatabase** resources.
Shows how to feed the .CSV files from the Server Role Requirements Calculator
into the resource.
The example code for ConfigureDatabases-FromCalculator is located in
"ConfigureDatabases-FromCalculator.ps1" in the module folder under ...\xExchange\Examples\ConfigureDatabases-FromCalculator.

### ConfigureDatabases-Manual

Configures primary databases and database copies using the **xExchMailboxDatabase**,
**xExchMailboxDatabaseCopy**, and **xExchWaitForMailboxDatabase** resources.
Configures database list manually.
The example code for ConfigureDatabases-Manual is located in
"ConfigureDatabases-Manual.ps1" in the module folder under ...\xExchange\Examples\ConfigureDatabases-Manual.

### ConfigureNamespaces

Contains three different examples, **SingleNamespace**, **RegionalNamespaces**,
and **InternetFacingSite**, which show different ways to
configure Client Access Namespaces.
The three examples are in separate folders the module folder under ...\xExchange\Examples\PostInstallationConfiguration.

### ConfigureVirtualDirectories

Configures various properties on Exchange Virtual Directories, like URL's
and Authentication settings.
The example code for ConfigureVirtualDirectories is located in
"ConfigureVirtualDirectories-Manual.ps1" in the module folder under ...\xExchange\Examples\ConfigureVirtualDirectories.

### CreateAndConfigureDAG

Creates a Database Availability Group, creates two new DAG networks and removes
the default DAG network, and adds members to the DAG.
The example code for CreateAndConfigureDAG is located in "CreateAndConfigureDAG.ps1"
in the module folder under ...\xExchange\Examples\CreateAndConfigureDAG.

### EndToEndExample

An end to end example of how to deploy and configure an Exchange Server.
The example scripts run Jetstress, install Exchange, create the DAG and databases,
and configure other Exchange settings.
The example code for EndToEndExample is located in in the module folder under ...\xExchange\Examples\EndToEndExample.

### InstallExchange

Shows how to install Exchange using the **xExchInstall** resource.
The example code for InstallExchange is located in "InstallExchange.ps1" in the
module folder under ...\xExchange\Examples\InstallExchange.

### JetstressAutomation

Contains two separate example scripts which show how to use the **xExchJetstress**
resource to automate running Jetstress, and the **xExchJetstressCleanup** resource
to cleanup a Jetstress installation.
The example code for JetstressAutomation is located in "1-InstallAndRunJetstress.ps1"
and "2-CleanupJetstress.ps1" in the module folder under ...\xExchange\Examples\JetstressAutomation.

### MaintenanceMode

Shows examples of how to prepare for maintenance mode, enter maintenance mode,
and exit maintenance mode. MaintenanceModePrep.ps1 prepares a server for
maintenance mode by setting DatabaseCopyAutoActivationPolicy to Blocked using a
Domain Controller in both the primary and secondary site. If multiple servers are
going to be entering maintenance mode at the same time, this step can help prevent
these servers from failing over databases to each other. MaintenanceModeStart.ps1
puts a server into maintenance mode. MaintenanceModeStop.ps1 takes a server out
of maintenance mode.

### PostInstallationConfiguration

Shows how to use the majority of the post-installation resources in the
**xExchange** module.
The example code for PostInstallationConfiguration is located in
"PostInstallationConfiguration.ps1" in the module folder under ...\xExchange\Examples\PostInstallationConfiguration.

### WaitForADPrep

Shows how to use the **xExchWaitForADPrep** resource to ensure that
Setup /PrepareSchema and /PrepareAD were run successfully.
The example code for WaitForADPrep is located in "WaitForADPrep.ps1"
in the module folder under ...\xExchange\Examples\WaitForADPrep.
