#set_unless[:db_mssql][:install_config][:instance] = "MSSQLSERVER"
#set_unless[:db_mssql][:install_config][:action] = "Install"
#set_unless[:db_mssql][:install_config][:features] = "SQLENGINE,REPLICATION,FULLTEXT,SSMS,ADV_SSMS"
#set_unless[:db_mssql][:install_config][:program_dir] = "C:\Program Files\Microsoft SQL Server"
#set_unless[:db_mssql][:install_config][:program_dir_wow64] = "C:\Program Files (x86)\Microsoft SQL Server"

default[:db_mssql][:mirror_listen_port] = "5022"
default[:db_mssql][:mirror_listen_ip] = "ALL"

default[:db_mssql][:backup_dir] = "C:/sql_backups"