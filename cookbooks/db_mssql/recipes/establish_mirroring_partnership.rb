#
# Cookbook Name:: db_mssql
# Recipe:: establish_mirroring_partnership
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

# Working from these steps http://weblogs.sqlteam.com/tarad/archive/2007/02/13/60091.aspx

backup_dir = "C:/tmp/sql_mirror_backup/"

directory backup_dir do
  recursive true
  action :create
end

# Create a full backup, then transaction log backup of the target database
db_sqlserver_database node[:db_mssql][:database_name] do
  machine_type = node[:kernel][:machine]
  backup_dir_path backup_dir
  backup_file_name_format node[:db_sqlserver][:backup][:backup_file_name_format]
  existing_backup_file_name_pattern node[:db_sqlserver][:backup][:existing_backup_file_name_pattern]
  server_name node[:db_sqlserver][:server_name]
  force_restore false
  zip_backup true
  delete_sql_after_zip true
  max_old_backups_to_keep node[:db_sqlserver][:backup][:backups_to_keep]
  action :backup
end

# Upload the full backup and transaction log backup (in a zip file) to S3 for the mirror server to fetch
rjg_aws_s3 "Upload database backup to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:s3][:bucket_backups]
  s3_file "mirror/#{node['backupfilename']}"
  file_path ::File.join(backup_dir, node['backupfilename'])
  action :put
  notifies :delete, resources(:directory => backup_dir), :immediately
end

# Tell the mirror server to get all setup
remote_recipe "Initialize the mirror" do
  recipe "db_mssql::initialize_mirror"
  attributes({
    :db_sqlserver => node[:db_sqlserver],
    :db_mssql => node[:db_mssql].merge({
      :mirror_backup_file => node['backupfilename'],
      :mirror_partner => node[:db_mssql][:nickname]
    }),
    :aws => node[:aws],
    :s3 => node[:s3]
  })
  recipents_tags ["mssql_server:nickname=#{node[:db_mssql][:mirror_partner]}"]
end