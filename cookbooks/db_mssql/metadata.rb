maintainer "Ryan J. Geyer"
maintainer_email "rgeyer@its.jnj.com"
description "Microsoft SQL 2008 Enterprise Bits"
long_description "Microsoft SQL 2008 Enterprise Bits"
name "db_mssql"
version "0.0.1"

depends "db_sqlserver"

recipe "db_mssql::default", "Runs db_mssql::install"
recipe "db_mssql::install", "Installs Microsoft SQL 2008 Enterprise Server with specified options"
recipe "db_mssql::add_sysadmin", "Adds a user (or group) as a sysadmin for the entire server"

attribute "db_mssql/security_mode",
  :display_name => "What type of logins the server will accept.  Only Active Directory logins if set to 'Windows', mixed mode if set to 'SQL'",
  :description => "What type of logins the server will accept.  Only Active Directory logins if set to 'Windows', mixed mode if set to 'SQL'",
  :recipes => [
    "db_mssql::default",
    "db_mssql::install"
  ],
  :choice => [
    "Windows",
    "SQL"
  ],
  :required => "required"

attribute "db_mssql/sysadmin_user",
  :display_name => "Sysadmin Username or Group",
  :description => "The username or group name to make a sysadmin",
  :recipes => ["db_mssql::add_sysadmin"]

attribute "db_mssql/server_name",
  :display_name => "SQL Server instance network name",
  :description => "The network name of the SQL Server instance used by recipes. Ex: 'localhost\\SQLEXPRESS' for SQL EXPRESS or 'localhost' for SQL STANDARD",
  :recipes => ["db_mssql::add_sysadmin"],
  :required => true