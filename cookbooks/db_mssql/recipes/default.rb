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

skeme_tag "mssql_server:nickname=#{node[:db_mssql][:nickname]}" do
  action :add
end
skeme_tag "mssql_server:my_ip_for_mirroring_partner=#{node[:db_mssql][:my_ip_for_mirroring_partner]}" do
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
else
  remote_file 'C:/powershell_scripts/sql/functions.ps1' do
  source "functions.ps1"
  end
end

directory node[:db_mssql][:backup_dir] do
  recursive true
  action :create
end

template maintenance_script do
  source "MaintenanceSolution.sql.erb"
  variables(:backup_dir => node[:db_mssql][:backup_dir])
  backup false
end

db_sqlserver_database "master" do
  server_name node[:db_sqlserver][:server_name]
  script_path maintenance_script
  action :run_script
end