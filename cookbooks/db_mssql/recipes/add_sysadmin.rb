#
# Cookbook Name:: db_mssql
# Recipe:: add_sysadmin
#
#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

db_sqlserver_database "master" do
  server_name node[:db_mssql][:server_name]
  commands ["CREATE LOGIN [#{node[:db_mssql][:sysadmin_user]}] FROM WINDOWS;",
    "EXEC sp_addsrvrolemember @loginame = N'#{node[:db_mssql][:sysadmin_user]}', @rolename = N'sysadmin';" ]
#  commands ["CREATE LOGIN [#{node[:db_mssql][:sysadmin_user]}] FROM WINDOWS;",
#    "EXEC sp_addsrvrolemember @loginame = N'#{node[:db_mssql][:sysadmin_user]}', @rolename = N'sysadmin';"
#  ]
  action :run_command
end