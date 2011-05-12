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

function Do-Reboot()
{
  $computer = get-content env:computername
  $system = Get-WmiObject Win32_OperatingSystem -ComputerName $computer
  $system.psbase.Scope.Options.EnablePrivileges = $true
  #redirecting the output to $null to avoid script failure
  $system.Reboot() > $null
  Write-Output "Reboot signal sent!"
}

$node_attr = Get-NewResource node_attribute
$do_reboot = Get-ChefNode $node_attr

if($do_reboot)
{
  Do-Reboot
}