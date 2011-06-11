#
# Cookbook Name:: db_mssql
# Recipe:: sql_backup
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
  commands ["EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES', @Directory = N'#{node[:db_mssql][:backup_vol_driveletter]}:\\', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = #{node[:db_mssql][:backup_cleanup_time]}, @CheckSum = 'Y'"]
  action :run_command
end