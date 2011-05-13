#
# Cookbook Name:: iis7
# Recipe:: enable_sessionstate_server
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

include_recipe "rjg_utils::install_roles_and_features"

rjg_utils_add_role_or_feature "Web-Asp-Net"

powershell "Configure session state server" do
  ps_code = <<-EOF
$appcmd_path = $env:systemroot + "\\system32\\inetsrv\\APPCMD.exe"
$appcmd_exists = Test-Path $appcmd_path
if ($appcmd_exists)
{
  $state_server_exists = &$appcmd_path list CONFIG /section:sessionState | findstr StateServer
  if([string]::IsNullOrEmpty($state_server_exists))
  {
    Write-Output "Configuring session state server"
    &$appcmd_path set CONFIG /commit:WEBROOT /section:sessionState /mode:StateServer

    $service_name = "aspnet_state"

    Set-Service $service_name -startupType automatic
    Start-Service $service_name
  }
  else
  {
    Write-Output "Session state server already installed and configured, skipping"
  }
  Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\aspnet_state\\Parameters -Name AllowRemoteConnection -Value 1 -Type dword
}
else
{
  Write-Output "APPCMD.EXE is missing, this script is only compatible with Windows 2008"
  exit -1
}
  EOF

  source(ps_code)
end