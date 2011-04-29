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

right_link_tag "mssql_server:nickname=#{node[:db_mssql][:nickname]}"
right_link_tag "mssql_server:my_ip_for_mirroring_partner=#{node[:db_mssql][:my_ip_for_mirroring_partner]}"