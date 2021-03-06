#
# Cookbook Name:: db_mssql
# Recipe:: initialize_mirror
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

include_recipe "skeme::default"

require 'yaml'

backup_dir = ::File.join(ENV['TMP'], 'sql_mirror_backup')

# TODO: This is duplicated in db_mssql::establish_mirroring_partnership, in db_mssql::initialize_mirror, and in the outbound endpoint definition.  May want to fix that
cert_name = "#{node[:db_mssql][:nickname]}_mirror_cert"
cert_filename = "#{cert_name}.cer"

remote_hash = {
  :remote => {
    :db_mssql => {
      :database_name => node[:remote][:db_mssql][:database_name],
      :mirror_bucket => node[:remote][:db_mssql][:mirror_bucket],
      :mirror_partner => node[:db_mssql][:nickname],
      :mirror_partner_hostname => node[:db_mssql][:my_hostname_for_mirroring_partner],
      :mirror_listen_port => node[:remote][:db_mssql][:mirror_listen_port],
      :mirror_password => node[:remote][:db_mssql][:mirror_password],
      :partner_certificate => cert_filename
    },
    :aws => {
      :access_key_id => node[:remote][:aws][:access_key_id],
      :secret_access_key => node[:remote][:aws][:secret_access_key]
    }
  }
}

directory backup_dir do
  recursive true
  action [:delete, :create]
end

# Download & restore DB
aws_s3 "Download backup from S3" do
  access_key_id node[:remote][:aws][:access_key_id]
  secret_access_key node[:remote][:aws][:secret_access_key]
  s3_bucket node[:remote][:db_mssql][:mirror_bucket]
  s3_file node[:remote][:db_mssql][:mirror_backup_file]
  download_dir backup_dir
  action :get
end

# TODO: This pattern (zipping and unzipping files) is repeated a lot, should probably be captured in a LWRP or a definition
powershell "Unzip the backup file" do
  parameters({'ZIP_FILE' => ::File.join(backup_dir, node[:remote][:db_mssql][:mirror_backup_file]), 'DEST_DIR' => backup_dir})

  ps_code = <<-EOF
$command='cmd /c 7z x -y "'+$env:ZIP_FILE+'" -o"'+$env:DEST_DIR+'""'
$command_ouput=invoke-expression $command
if (!($command_ouput -match 'Everything is Ok'))
{
    echo $command_ouput
    Write-Error "Error: Unzipping failed"
    exit 144
}
  EOF

  source(ps_code)
end

#db_sqlserver_database node[:remote][:db_mssql][:database_name] do
#  machine_type = node[:kernel][:machine]
#  backup_dir_path backup_dir
#  existing_backup_file_name_pattern node[:db_sqlserver][:backup][:existing_backup_file_name_pattern]
#  server_name node[:db_sqlserver][:server_name]
#  force_restore true
#  restore_norecovery true
#  action :restore
#end

# TODO: What to do when the DB exists, and/or is already mirroring? In the case of a failed mirroring attempt, the restored DB may exist, and have
# a mirroring partner set, but there is no (obvious) way to detect that, running ALTER DATABASE <db> SET PARTNER OFF will break if no partner is set.

# http://beyondrelational.com/blogs/sqlmaster/archive/2010/09/29/sql-server-high-availability-quick-view-of-database-mirroring-session-between-partners.aspx

db_sqlserver_database "master" do
  server_name node[:db_mssql][:server_name]
  commands [
    "RESTORE DATABASE [#{node[:remote][:db_mssql][:database_name]}] FROM DISK = '#{::File.join(backup_dir, 'backup.bak')}' WITH FILE=1, NORECOVERY",
    "RESTORE LOG [#{node[:remote][:db_mssql][:database_name]}] FROM DISK = '#{::File.join(backup_dir, 'backup.trn')}' WITH FILE=1, NORECOVERY"
           ]
  action :run_command
  #notifies :delete, resources(:directory => backup_dir), :immediately
end
# /Download & restore DB

db_mssql_enable_outbound_certificate_auth_mirror_endpoint "Enable outbound mirroring endpoint" do
  server_name node[:db_mssql][:server_name]
  nickname node[:db_mssql][:nickname]
  mirror_password node[:remote][:db_mssql][:mirror_password]
  aws_access_key_id node[:remote][:aws][:access_key_id]
  aws_secret_access_key node[:remote][:aws][:secret_access_key]
  s3_bucket node[:remote][:db_mssql][:mirror_bucket]
  mirror_listen_port node[:remote][:db_mssql][:mirror_listen_port]
  mirror_listen_ip node[:db_mssql][:mirror_listen_ip]
end

db_mssql_enable_inbound_certificate_auth_mirror_endpoint "Enable inbound mirroring endpoint" do
  server_name node[:db_mssql][:server_name]
  partner_certificate node[:remote][:db_mssql][:partner_certificate]
  mirror_partner node[:remote][:db_mssql][:mirror_partner]
  mirror_password node[:remote][:db_mssql][:mirror_password]
  aws_access_key_id node[:remote][:aws][:access_key_id]
  aws_secret_access_key node[:remote][:aws][:secret_access_key]
  s3_bucket node[:remote][:db_mssql][:mirror_bucket]
end

# Partner up with the primary/principal server
db_sqlserver_database "master" do  # node[:db_mssql][:database_name] do
  server_name node[:db_mssql][:server_name]
  commands ["ALTER DATABASE #{node[:remote][:db_mssql][:database_name]} SET PARTNER = N'TCP://#{node[:remote][:db_mssql][:mirror_partner_hostname]}:#{node[:remote][:db_mssql][:mirror_listen_port]}'"]
  action :run_command
end

Chef::Log.info("Sending the following inputs/attributes to db_mssql::initialize_principal on the first server with the tag - mssql_server:nickname=#{node[:remote][:db_mssql][:mirror_partner]}")
Chef::Log.info(remote_hash.to_yaml)

# Tell the principal server to reciprocate and hook up with me!
remote_recipe "Initialize the principal" do
  recipe "db_mssql::initialize_principal"
  attributes(remote_hash)
  recipients_tags ["mssql_server:nickname=#{node[:remote][:db_mssql][:mirror_partner]}"]
  scope :single
end

skeme_tag "mssql_server:mirror_for_db=#{node[:remote][:db_mssql][:database_name]}" do
  action :add
end