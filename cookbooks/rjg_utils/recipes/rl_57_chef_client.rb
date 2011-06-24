#
# Cookbook Name:: rjg_utils
# Recipe:: rl_57_chef_client
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

%w{cache backup}.each do |dir|
  directory "C:/chef/#{dir}" do
    recursive true
    action :create
  end
end

ruby_block "Make me a validator key" do
  block do
    File.open("C:/chef/validation.pem", "w") do |f|
      f.print node[:rl_57_chef_client][:validator]
    end
  end
end

template "C:/chef/client.rb" do
  source "client.rb.erb"
end