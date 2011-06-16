#
# Cookbook Name:: db_mssql
# Recipe:: default
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

maintenance_script = ::File.join(ENV['TMP'], "maintenance.sql")
backup_lineage = "#{node[:db_mssql][:nickname]}-db-backups"

skeme_tag "mssql_server:nickname=#{node[:db_mssql][:nickname]}" do
  action :add
end
skeme_tag "mssql_server:my_hostname_for_mirroring_partner=#{node[:db_mssql][:my_hostname_for_mirroring_partner]}" do
  action :add
end

directory 'C:/powershell_scripts/sql/' do
  recursive true
  action :create
end

if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
  cookbook_file 'C:/powershell_scripts/sql/functions.ps1' do
    source "functions.ps1"
  end

  cookbook_file maintenance_script do
    source "MaintenanceSolution.sql"
  end
else
  remote_file 'C:/powershell_scripts/sql/functions.ps1' do
    source "functions.ps1"
  end

  remote_file maintenance_script do
    source "MaintenanceSolution.sql"
  end
end

db_sqlserver_database "master" do
  server_name node[:db_mssql][:server_name]
  script_path maintenance_script
  action :run_script
end

# TODO: Permit RightScale tagging support by passing credentials
ebs_conductor_attach_lineage "Attach SQL Backup Volume in lineage #{backup_lineage}" do
  lineage backup_lineage
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  vol_size_in_gb node[:db_mssql][:backup_vol_size_in_gb]
  if node[:db_mssql][:backup_vol_snapshot_id]
    snapshot_id node[:db_mssql][:backup_vol_snapshot_id]
  end
  mountpoint node[:db_mssql][:backup_vol_driveletter]
end