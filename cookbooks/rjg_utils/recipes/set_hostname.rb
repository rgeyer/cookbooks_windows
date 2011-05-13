#
# Cookbook Name:: rjg_utils
# Recipe:: set_hostname
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

rjg_utils_system "Reboot System For Hostname" do
  node_attribute "rjg_utils_hostname_reboot"
  action :nothing
end

powershell "Set the computer hostname and workgroup name" do
  parameters({
    'HOSTNAME' => node[:rjg_utils][:hostname],
    'WORKGROUP' => node[:rjg_utils][:workgroup]
  })

  powershell_script = <<'EOF'
function Windows-NameCleanse([String]$name, [Boolean]$allowDot=$false)
{
  $regex = "[^0-9a-zA-Z_]"
  if($allowDot) { $regex = "[^0-9a-zA-Z_\.]" }
  # The regex cleans things up so all is well.
  $NewName = $name -replace $regex,"-"
  $NewName = $NewName.ToUpper()
  # Shorten it to 16 characters
  if($NewName.length -gt 16) {
    $NewName = $NewName.SubString(0, 15)
  }
  return $NewName
}

$needsReboot = $false

$NewComputerName = Windows-NameCleanse $env:HOSTNAME
$NewWorkgroupName = Windows-NameCleanse -name $env:WORKGROUP -allowDot $true

$computerinfo = Get-WmiObject -class win32_computersystem

$CurrentComputerName = $env:COMPUTERNAME.ToUpper()
$CurrentWorkgroupName = $computerinfo.Workgroup

$programFilesPath = "C:\Program Files"
echo "The progam files dir is set to $programFilesPath"
$ec2ConfigFile = "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml"
[xml]$ec2configXml = get-content $ec2ConfigFile
$compNameNode = $ec2ConfigXml.SelectSingleNode("/Ec2ConfigurationSettings/Plugins/Plugin[Name='Ec2SetComputerName']")
if($compNameNode.State -ne 'Disabled')
{
write-output "Disabling the Ec2ConfigService setting to set the hostname on boot"
  $compNameNode.State = 'Disabled'
  if (Test-Path "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml.bak") {
    del "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml.bak"
  }
  move $ec2ConfigFile "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml.bak"
  $ec2ConfigXml.save($ec2ConfigFile)
}
else
{
  write-output "The Ec2ConfigService has already been modified"
}

if( $NewComputerName.CompareTo($CurrentComputerName) -ne 0 ) {
  write-output "Setting hostname to $NewComputerName"
  $computerinfo.Rename($NewComputerName)
  $needsReboot = $true
}

if( $NewWorkgroupName.CompareTo($CurrentWorkgroupName) -ne 0 ) {
  write-output "Joining workgroup $NewWorkgroupName"
  $computerinfo.JoinDomainOrWorkgroup($env:WORKGROUP)
  $needsReboot = $true
}

if(!$needsReboot)
{
  write-output("The hostname was already set to $NewComputerName.$NewWorkgroupName, hostname was not changed")
}
#$setval = $rjg_utils_reboot -or $needsReboot
#Set-ChefNode rjg_utils_reboot -BooleanValue $setval
Set-ChefNode rjg_utils_hostname_reboot -BooleanValue $needsReboot
EOF

  source(powershell_script)
  notifies :conditional_reboot, resources(:rjg_utils_system => "Reboot System For Hostname"), :delayed
end