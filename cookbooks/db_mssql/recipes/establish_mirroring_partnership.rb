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
# Something more up-to-date and with powershell examples http://nexus.realtimepublishers.com/content/?tip=how-to-configure-data-mirroring-in-sql-server-2008-with-windows-powershell

require 'yaml'

backup_dir = "C:/tmp/sql_mirror_backup/"
backup_filename = "#{node[:db_mssql][:database_name]}.zip"
backup_filepath = ::File.join(backup_dir,backup_filename)

remote_hash = {
  :db_mssql => {
    :database_name => node[:db_mssql][:database_name],
    :mirror_bucket => node[:db_mssql][:mirror_bucket],
    :mirror_backup_file => backup_filename,
    :mirror_partner => node[:db_mssql][:nickname],
    :mirror_partner_ip => node[:db_mssql][:my_ip_for_mirroring_partner],
    :mirror_listen_port => node[:db_mssql][:mirror_listen_port],
    :partner_certificate => cert_filename
# Let the mirror server define it's own listen ip, since we might want it to only listen on a local IP, which we don't know here
#    :mirror_listen_ip => node[:db_mssql][:mirror_listen_ip]
  },
  :aws => {
    :access_key_id => node[:aws][:access_key_id],
    :secret_access_key => node[:aws][:secret_access_key]
  }
}

directory backup_dir do
  recursive true
  action [:delete, :create]
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

# TODO: can't use node['backupfilename'] or node[:backupfilename] because they are evaulated at compile time.. Shit..
powershell "Rename the backup file to something standard" do
  parameters({'BACKUP_DIR' => backup_dir, 'BACKUP_FILENAME' => backup_filepath})

  ps_code = <<-EOF
$backup_dir_contents = Get-ChildItem $env:BACKUP_DIR -filter "*.zip"
$file_count - $backup_dir_contets.Count

# Get-ChildItem returns a System.IO.FileSystemInfo if there is only one file in a directory, which is our desired
# state when we run this script.

if($file_count -eq $null)
{
  $file_to_move = $backup_dir_contents.FullName
  Write-Output "Moving $file_to_move to $env:BACKUP_FILENAME"
  Move-Item "$file_to_move" "$env:BACKUP_FILENAME"
}
else
{
  Write-Output "Found $file_count items in $env:BACKUP_DIR - No files were moved!"
  foreach($file in $backup_dir_contents) { Write-Output "Found $_" }
}
  EOF

  source(ps_code)
end

# Upload the full backup and transaction log backup (in a zip file) to S3 for the mirror server to fetch
aws_s3 "Upload database backup to S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:db_mssql][:mirror_bucket]
  s3_file backup_filename
  file_path backup_filepath
  action :put
end

db_mssql_enable_outbound_certificate_auth_mirror_endpoint "Enable outbound mirroring endpoint" do
  server_name node[:db_sqlserver][:server_name]
  nickname node[:db_mssql][:nickname]
  mirror_password node[:db_mssql][:mirror_password]
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:db_mssql][:mirror_bucket]
  mirror_listen_port node[:db_mssql][:mirror_listen_port]
  mirror_listen_ip node[:db_mssql][:mirror_listen_ip]
end

Chef::Log.info("Sending the following inputs/attributes to db_mssql::initialize_mirror on the first server with the tag - mssql_server:nickname=#{node[:db_mssql][:mirror_partner]}")
Chef::Log.info(remote_hash.to_yaml)

# Tell the mirror server to get all setup
remote_recipe "Initialize the mirror" do
  recipe "db_mssql::initialize_mirror"
  attributes(remote_hash)
  recipients_tags ["mssql_server:nickname=#{node[:db_mssql][:mirror_partner]}"]
  scope :single
end