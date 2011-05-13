#
# Cookbook Name:: rjg_utils
# Recipe:: set_uac
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

rjg_utils_system "Reboot System For UAC" do
  node_attribute "rjg_utils_uac_reboot"
  action :nothing
end

powershell "Set UAC" do
  pscode = <<'EOF'
$enable_uac_node_attr = Get-ChefNode rjg_utils, enable_uac
$reg_path = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system"
$needsReboot = $false

if($enable_uac_node_attr -eq "true")
{
  $desired_setting = 1
}
else
{
  $desired_setting = 0
}


$uac_val = Get-ItemProperty -Path $reg_path -Name EnableLUA
if($desired_setting -ne $uac_val.EnableLUA)
{
  Write-Output "Setting UAC to $enable_uac_node_attr"
  Set-ItemProperty -Path $reg_path -Name EnableLUA -Value $desired_setting -Type dword
  $needsReboot = $true
}
else
{
  Write-Output "UAC was already set to $enable_uac_node_attr.  Skipping..."
}
#$setval = $rjg_utils_reboot -or $needsReboot
#Set-ChefNode rjg_utils_reboot -BooleanValue $setval
Set-ChefNode rjg_utils_uac_reboot -BooleanValue $needsReboot
EOF

  source(pscode)
  notifies :conditional_reboot, resources(:rjg_utils_system => "Reboot System For UAC"), :delayed
end