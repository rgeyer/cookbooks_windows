#
# Cookbook Name:: db_mssql
# Powershell Resource:: certificate
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

actions :create, :backup, :drop

attribute :cert_name, :kind_of => [String], :required => true, :name_attribute => true
attribute :server_network_name, :kind_of => [String], :required => true
attribute :overwrite, :equal_to => [true, false], :default => false
attribute :import_on_create, :equal_to => [true, false], :default => false
attribute :username, :kind_of => [String]
attribute :filename, :kind_of => [String]