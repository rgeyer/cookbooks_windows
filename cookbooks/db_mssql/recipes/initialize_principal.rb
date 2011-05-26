#
# Cookbook Name:: db_mssql
# Recipe:: initialize_principal
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

include_recipe "skeme::default"

db_mssql_enable_inbound_certificate_auth_mirror_endpoint "Enable inbound mirroring endpoint" do
  partner_certificate node[:db_mssql][:partner_certificate]
  mirror_partner node[:db_mssql][:mirror_partner]
  mirror_password node[:db_mssql][:mirror_password]
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  s3_bucket node[:db_mssql][:mirror_bucket]
end

# Partner up with the mirror server
# TODO: This is currently setting up a "high safety" mirror (synchronous) because we're setting safety to full and witness to off.  Might want to provide
# other options?
db_sqlserver_database "master" do  # node[:db_mssql][:database_name] do
  server_name node[:db_sqlserver][:server_name]
  commands [
    "ALTER DATABASE #{node[:db_mssql][:database_name]} SET PARTNER = N'TCP://#{node[:db_mssql][:mirror_partner_ip]}:#{node[:db_mssql][:mirror_listen_port]}'",
    "ALTER DATABASE #{node[:db_mssql][:database_name]} SET SAFETY FULL",
    "ALTER DATABASE #{node[:db_mssql][:database_name]} SET WITNESS OFF"
  ]
  action :run_command
end

skeme_tag "mssql_server:principal_for_db=#{node[:db_mssql][:database_name]}" do
  action :add
end