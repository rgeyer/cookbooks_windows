#
# Cookbook Name:: db_mssql
# Definition:: enable_inbound_certificate_auth_mirror_endpoint
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

define :db_mssql_enable_inbound_certificate_auth_mirror_endpoint,
       :partner_certificate => nil,
       :mirror_partner => nil,
       :mirror_password => nil,
       :aws_access_key_id => nil,
       :aws_secret_access_key => nil,
       :s3_bucket => nil do

  backup_dir = "#{ENV['TMP']}\\mirrorendpoint"

  partner_login = "#{params[:mirror_partner]}_mirror_login"
  partner_user = "#{params[:mirror_partner]}_mirror_user"
  partner_cert_name = "#{params[:mirror_partner]}_mirror_cert"
  partner_cert_filename = "#{partner_cert_name}.cer"
  partner_cert_filepath = "#{backup_dir}\\#{partner_cert_filename}"

  directory backup_dir do
    recursive true
    action [:delete, :create]
  end

  aws_s3 "Download partner certificate from S3" do
    access_key_id params[:aws_access_key_id]
    secret_access_key params[:aws_secret_access_key]
    s3_bucket params[:s3_bucket]
    s3_file params[:partner_certificate]
    file_path partner_cert_filepath
    action :get
  end

  db_mssql_login partner_login do
    password params[:mirror_password]
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
    action :create
  end

  db_sqlserver_database "master" do
    server_name node[:db_mssql][:server_name]
    commands ["GRANT CONNECT ON ENDPOINT::mirror_endpoint TO [#{partner_user}]"]
  end
end