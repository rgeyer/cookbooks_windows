maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description "Microsoft SQL 2008 (Standard & Express) Bits"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
name "db_mssql"
version "0.0.1"

depends "db_sqlserver"
depends "rjg_aws"

recipe "db_mssql::default", "Tags the server instance with a nickname so it can be easily located later for mirroring activities"
recipe "db_mssql::add_sysadmin", "Adds a user (or group) as a sysadmin for the entire server"
recipe "db_mssql::establish_mirroring_partnership", "To be run from the server containing the database to be mirroed.  This server will become the principal in the relationship."
recipe "db_mssql::initialize_mirror", "Downloads a full, and transaction log backup (created by the principal server) from S3.  The backup is restored with NORECOVERY and mirroring is configured.  This is usually intended to be called remotely by the principal server when db_mssql::establish_mirroring_partnership is used."
recipe "db_mssql::initialize_principal", "Causes the principal server to create a mirror partnership with the mirror.  The mirror configuration is high-performance (asynchronous).  This is usually intended to be called remotely by the mirror server when db_mssql::initialize_mirror is used."

attribute "db_mssql/sysadmin_user",
  :display_name => "Sysadmin Username or Group",
  :description => "The username or group name to make a sysadmin",
  :recipes => ["db_mssql::add_sysadmin"]

attribute "db_mssql/server_name",
  :display_name => "SQL Server instance network name",
  :description => "The network name of the SQL Server instance used by recipes. Ex: 'localhost\\SQLEXPRESS' for SQL EXPRESS or 'localhost' for SQL STANDARD",
  :recipes => ["db_mssql::add_sysadmin"],
  :required => "required"

attribute "db_mssql/nickname",
  :display_name => "SQL Server nickname",
  :description => "A unique memorable name for this mssql server.  Used for activities like mirroring etc, where actions must be performed on more than one sql server.",
  :recipes => ["db_mssql::default"],
  :required => "required"

attribute "db_mssql/database_name",
  :display_name => "SQL Database Name",
  :description => "The name of the database to perform the action on",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror","db_mssql::initialize_principal"],
  :required => "required"

attribute "db_mssql/mirror_partner",
  :display_name => "SQL Mirror Partner nickname",
  :description => "The nickname (set in db_mssql::default, defined by db_mssql/nickname) of the other server in the mirroring partnership",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"],
  :required => "required"

attribute "db_mssql/mirror_partner_ip",
  :display_name => "SQL Mirror Partner IP/Hostname",
  :description => "The ip address (or hostname) of the opposite side of the mirroring partnership.",
  :recipes => ["db_mssql::initialize_mirror","db_mssql::initialize_principal"],
  :required => "required"

attribute "db_mssql/my_ip_for_mirroring_partner",
  :display_name => "SQL Mirror My IP",
  :description => "The ip address (or hostname) that partners connecting to this node should use.  This should be set to something like $env:EC2_PUBLIC_IPV4",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::default"],
  :required => "required"

attribute "db_mssql/mirror_backup_file",
  :display_name => "SQL Mirror Backup File",
  :description => "The name (key) of the file in S3 under the s3/bucket_backups bucket which will be downloaded, and restored in order to create the mirrored relationship with db_mssql/mirror_partner",
  :recipes => ["db_mssql::initialize_mirror"],
  :required => "required"

attribute "db_mssql/mirror_listen_port",
  :display_name => "SQL Mirroring Endpoint Port",
  :description => "The port that the mirroring endpoint will listen on",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror","db_mssql::initialize_principal"],
  :required => "optional",
  :default => "5022"

attribute "db_mssql/mirror_listen_ip",
  :display_name => "SQL Mirror Endpoint Listener IP",
  :description => "The IP address(es) that the mirroring endpoint will listen on.  Defaults to 'ALL' but any option defined in the 'TCP Protocol Option' section of (http://technet.microsoft.com/en-us/library/ms181591.aspx) is acceptable",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"],
  :required => "optional",
  :default => "ALL"

# AWS copy/paste
attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"],
  :required => "required"

# db_sqlserver copy/paste
attribute "db_sqlserver/server_name",
  :display_name => "SQL Server instance network name",
  :description => "The network name of the SQL Server instance used by recipes. Ex: 'localhost\\SQLEXPRESS' for SQL EXPRESS or 'localhost' for SQL STANDARD",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror","db_mssql::initialize_principal"],
  :required => "required"

attribute "db_sqlserver/backup/backup_file_name_format",
  :display_name => "Backup file name format",
  :description => "Format string with Powershell-style string format arguments for creating backup files. The 0 argument represents the database name, the 1 argument represents a generated time stamp and the 2 argument represents the backup contents (one of 'full' or 'log' indicating a full backup or transactional log backup). Ex: {0}_{1}_{2}.bak",
  :default => "{0}_{1}_{2}.bak",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"]

attribute "db_sqlserver/backup/existing_backup_file_name_pattern",
  :display_name => "Pattern matching backup file names",
  :description => "Wildcard file matching pattern (i.e. not a Regex) with Powershell-style string format arguments for finding backup files. The 0 argument represents the database name and the rest of the pattern should match the file names generated from the backup_file_name_format. Ex: {0}_*.bak",
  :default => "{0}_*.bak",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"]

attribute "db_sqlserver/backup/backups_to_keep",
  :display_name => "Old backups to keep",
  :description => "Defines the number of old backups to keep. Ex: 30",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"],
  :required => "required"

attribute "s3/bucket_backups",
  :display_name => "Bucket to store backups",
  :description => "The name of the S3 bucket. Ex: production-bucket-backup",
  :recipes => ["db_mssql::establish_mirroring_partnership","db_mssql::initialize_mirror"],
  :required => "required"