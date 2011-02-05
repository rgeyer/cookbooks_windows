maintainer "Ryan J. Geyer"
maintainer_email "rgeyer@its.jnj.com"
description "Microsoft SQL 2008 Enterprise Bits"
long_description "Microsoft SQL 2008 Enterprise Bits"
name "db_mssql"
version "0.0.1"

depends "db_sqlserver"

recipe "db_mssql::default", "Nobody here but us chickens"
recipe "db_mssql::add_sysadmin", "Adds a user (or group) as a sysadmin for the entire server"

attribute "db_mssql/sysadmin_user",
  :display_name => "Sysadmin Username or Group",
  :description => "The username or group name to make a sysadmin",
  :recipes => ["db_mssql::add_sysadmin"]

attribute "db_mssql/server_name",
  :display_name => "SQL Server instance network name",
  :description => "The network name of the SQL Server instance used by recipes. Ex: 'localhost\\SQLEXPRESS' for SQL EXPRESS or 'localhost' for SQL STANDARD",
  :recipes => ["db_mssql::add_sysadmin"],
  :required => true