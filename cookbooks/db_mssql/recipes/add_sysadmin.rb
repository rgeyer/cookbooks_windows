db_sqlserver_database "master" do
  server_name node[:db_mssql][:server_name]
  commands ["CREATE LOGIN [#{node[:db_mssql][:sysadmin_user]}] FROM WINDOWS;",
    "EXEC sp_addsrvrolemember @loginame = N'#{node[:db_mssql][:sysadmin_user]}', @rolename = N'sysadmin';" ]
#  commands ["CREATE LOGIN [#{node[:db_mssql][:sysadmin_user]}] FROM WINDOWS;",
#    "EXEC sp_addsrvrolemember @loginame = N'#{node[:db_mssql][:sysadmin_user]}', @rolename = N'sysadmin';"
#  ]
  action :run_command
end