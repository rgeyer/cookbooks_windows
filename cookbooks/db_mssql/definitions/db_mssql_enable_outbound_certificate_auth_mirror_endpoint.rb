#
# Cookbook Name:: db_mssql
# Definition:: enable_outbound_certificate_auth_mirror_endpoint
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

define :db_mssql_enable_outbound_certificate_auth_mirror_endpoint,
       :server_name => nil,
       :nickname => nil,
       :mirror_password => nil,
       :aws_access_key_id => nil,
       :aws_secret_access_key => nil,
       :s3_bucket => nil,
       :mirror_listen_port => nil,
       :mirror_listen_ip => nil do
  backup_dir = "C:/tmp/mirrorendpoint/"
  master_key_backup_filename = "#{params[:nickname]}_master_key.key"
  master_key_backup_filepath = ::File.join(backup_dir, master_key_backup_filename)
  # TODO: This is duplicated in db_mssql::establish_mirroring_partnership, in db_mssql::initialize_mirror, and in the outbound endpoint definition.  May want to fix that
  cert_name = "#{params[:nickname]}_mirror_cert"
  cert_filename = "#{cert_name}.cer"
  cert_filepath = ::File.join(backup_dir, cert_filename)

  directory backup_dir do
    recursive true
    action [:delete, :create]
  end

  db_mssql_master_key "Create or overwrite the existing MSSQL master encryption key" do
    server_network_name params[:server_name]
    password params[:mirror_password]
    overwrite true
    filename master_key_backup_filepath
    action [:create, :backup]
  end

  aws_s3 "Upload master key backup to S3" do
    access_key_id params[:aws_access_key_id]
    secret_access_key params[:aws_secret_access_key]
    s3_bucket params[:s3_bucket]
    s3_file master_key_backup_filename
    file_path master_key_backup_filepath
    action :put
  end

  db_mssql_certificate "Create or overwrite a certificate named #{cert_name}" do
    import_on_create false
    overwrite true
    cert_name cert_name
    filename cert_filepath
    action [:create, :backup]
  end

  aws_s3 "Upload certificate backup to S3" do
    access_key_id params[:aws_access_key_id]
    secret_access_key params[:aws_secret_access_key]
    s3_bucket params[:s3_bucket]
    s3_file cert_filename
    file_path cert_filepath
    notifies :delete, resources(:directory => backup_dir), :immediately
    action :put
  end

  powershell "Prepare the mirroring endpoint" do
    parameters({
      'SERVER' => params[:server_name],
      'ENDPOINT_NAME' => 'mirror_endpoint',
      'LISTEN_PORT' => params[:mirror_listen_port],
      'LISTEN_IP' => params[:mirror_listen_ip],
      'MIRROR_PASSWORD' => params[:mirror_password]
    })

    source_file_path = ::File.expand_path(::File.join(::File.dirname(__FILE__), '..', 'files', 'default', 'create_mirroring_endpoint.ps1'))

    source_path(source_file_path)
  end
end