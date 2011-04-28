maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description "Microsoft SQL 2008 Enterprise Bits"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
name "db_mssql"
version "0.0.1"

depends "db_sqlserver"

recipe "db_mssql::default", "Tags the server instance with a nickname so it can be easily located later for mirroring activities"
recipe "db_mssql::add_sysadmin", "Adds a user (or group) as a sysadmin for the entire server"
recipe "db_mssql::establish_mirroring_partnership", "To be run from the server containing the database to be mirroed.  This server will become the principal in the relationship."

attribute "db_mssql/sysadmin_user",
  :display_name => "Sysadmin Username or Group",
  :description => "The username or group name to make a sysadmin",
  :recipes => ["db_mssql::add_sysadmin"]

attribute "db_mssql/server_name",
  :display_name => "SQL Server instance network name",
  :description => "The network name of the SQL Server instance used by recipes. Ex: 'localhost\\SQLEXPRESS' for SQL EXPRESS or 'localhost' for SQL STANDARD",
  :recipes => ["db_mssql::add_sysadmin"],
  :required => true

attribute "db_mssql/nickname",
  :display_name => "SQL Server nickname",
  :description => "A unique memorable name for this mssql server.  Used for activities like mirroring etc, where actions must be performed on more than one sql server.",
  :recipes => ["db_mssql::default"],
  :required => true