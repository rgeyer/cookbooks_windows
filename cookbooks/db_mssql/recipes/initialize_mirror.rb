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

require 'yaml'

backup_dir = "C:/tmp/sql_mirror_backup/"

partner_login = "#{node[:db_mssql][:mirror_partner]}_mirror_login"
partner_user = "#{node[:db_mssql][:mirror_partner]}_mirror_user"
partner_cert_name = "#{node[:db_mssql][:mirror_partner]}_mirror_cert"
partner_cert_filename = "#{partner_cert_name}.cer"
partner_cert_filepath = ::File.join(backup_dir, partner_cert_filename)

remote_hash = {
  :db_mssql => {
    :database_name => node[:db_mssql][:database_name],
    :mirror_bucket => node[:db_mssql][:mirror_bucket],
    :mirror_partner => node[:db_mssql][:nickname],
    :mirror_partner_ip => node[:db_mssql][:my_ip_for_mirroring_partner],
    :mirror_listen_port => node[:db_mssql][:mirror_listen_port],
    :partner_certificate => cert_filename
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

# Download & restore DB
aws_s3 "Download backup from S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:db_mssql][:mirror_bucket]
  s3_file node[:db_mssql][:mirror_backup_file]
  download_dir backup_dir
  action :get
end

# TODO: This pattern (zipping and unzipping files) is repeated a lot, should probably be captured in a LWRP or a definition
powershell "Unzip the backup file" do
  parameters({'ZIP_FILE' => ::File.join(backup_dir, "mirror", node[:db_mssql][:mirror_backup_file]), 'DEST_DIR' => backup_dir})

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

db_sqlserver_database node[:db_mssql][:database_name] do
  machine_type = node[:kernel][:machine]
  backup_dir_path backup_dir
  existing_backup_file_name_pattern node[:db_sqlserver][:backup][:existing_backup_file_name_pattern]
  server_name node[:db_sqlserver][:server_name]
  force_restore true
  restore_norecovery true
  action :restore
end
# /Download & restore DB

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

db_mssql_enable_inbound_certificate_auth_mirror_endpoint "Enable inbound mirroring endpoint" do
  partner_certificate node[:db_mssql][:partner_certificate]
  mirror_partner node[:db_mssql][:mirror_partner]
  mirror_password node[:db_mssql][:mirror_password]
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:db_mssql][:mirror_bucket]
end

# Create user and import certificate for inbound connections
aws_s3 "Download partner certificate from S3" do
  access_key_id node[:aws][:access_key_id]
  secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:db_mssql][:mirror_bucket]
  s3_file node[:db_mssql][:partner_certificate]
  file_path partner_cert_filepath
  action :get
end

db_mssql_login partner_login do
  password node[:db_mssql][:mirror_password]
  overwrite true
  action :create
end

db_mssql_user partner_user do
  login partner_login
  overwrite true
  action :create
end

db_mssql_certificate partner_cert_name do
  cert_name partner_cert_name
  overwrite true
  import_on_create true
  username partner_user
  filename partner_cert_filepath
  notifies :delete, resources(:directory => backup_dir), :immediately
  action :create
end

db_sqlserver_database "master" do
  server_name node[:db_sqlserver][:server_name]
  commands ["GRANT CONNECT ON ENDPOINT::mirror_endpoint TO [#{partner_user}]"]
end
# /Create user and import certificate for inbound connections

# Partner up with the primary/principal server
db_sqlserver_database "master" do  # node[:db_mssql][:database_name] do
  server_name node[:db_sqlserver][:server_name]
  commands ["ALTER DATABASE #{node[:db_mssql][:database_name]} SET PARTNER = N'TCP://#{node[:db_mssql][:mirror_partner_ip]}:#{node[:db_mssql][:mirror_listen_port]}'"]
  action :run_command
end

Chef::Log.info("Sending the following inputs/attributes to db_mssql::initialize_principal on the first server with the tag - mssql_server:nickname=#{node[:db_mssql][:mirror_partner]}")
Chef::Log.info(remote_hash.to_yaml)

# Tell the principal server to reciprocate and hook up with me!
remote_recipe "Initialize the principal" do
  recipe "db_mssql::initialize_principal"
  attributes(remote_hash)
  recipients_tags ["mssql_server:nickname=#{node[:db_mssql][:mirror_partner]}"]
  scope :single
end

right_link_tag "mssql_server:mirror_for_db=#{node[:db_mssql][:database_name]}"