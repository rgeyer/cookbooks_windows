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

backup_lineage = "#{node[:db_mssql][:nickname]}-db-backups"
history_to_keep = node[:db_mssql][:backup_cleanup_time] / 24

db_sqlserver_database "master" do
  server_name node[:db_mssql][:server_name]
  commands ["EXECUTE [dbo].[DatabaseBackup] @Databases = 'USER_DATABASES', @Directory = N'#{node[:db_mssql][:backup_vol_driveletter]}:\\', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = #{node[:db_mssql][:backup_cleanup_time]}, @CheckSum = 'Y'"]
  action :run_command
end

ebs_conductor_snapshot_lineage "Snapshot database backup lineage #{backup_lineage}" do
  lineage backup_lineage
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  mountpoint node[:db_mssql][:backup_vol_driveletter]
  history_to_keep history_to_keep.to_i
end