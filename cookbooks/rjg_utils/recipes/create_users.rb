#
# Cookbook Name:: rjg_utils
# Recipe:: create_users
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

require 'yaml'

users_dir = "C:/users"
users_file = "#{users_dir}/users.yml"

directory users_dir do
  recursive true
  action :create
end

rjg_aws_s3 "Download users YAML from S3" do
  access_key_id node[:rjg_utils][:users_access_key_id]
  secret_access_key node[:rjg_utils][:users_secret_access_key]
  s3_bucket node[:rjg_utils][:users_s3_bucket]
  s3_file node[:rjg_utils][:users_file]
  file_path users_file
  action :get
end

ruby_block "Deserialize the users file to a node attribute" do
  block do
    node[:users] = YAML.load_file(users_file)
  end
end

powershell "Create users" do
  ps_code = <<-EOF
$users = Get-ChefNode users

Write-Output $users

foreach($user in $users)
{
  Write-Output "Creating or updating user $user.user"

  $objUser = $null
  if(!([ADSI]::Exists("WinNT://localhost/$user.user")))
  {
    $objOu = [ADSI]"WinNT://localhost"
    $objUser = $objOU.Create("User", $user.user)
  }
  else
  {
    $objUser = [ADSI]"WinNT://localhost/$user.user, user"
  }


  $objUser.psbase.invoke("SetPassword", $user.pass)
  $objUser.psbase.CommitChanges()

  foreach($group in $user.groups)
  {
    Write-Output "Here's a group named $group"
  }
}
  EOF
end