#
# Cookbook Name:: rjg_utils
# Recipe:: set_timezone
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

powershell "Set Windows Timezone" do
  paramters({"TZ_OFFSET" => node[:rjg_utils][:tz_hash][node[:rjg_utils][:timezone]]})
  ps_code = <<'EOF'

$tz_offset = $env:TZOFFSET
$hostname = $env:COMPUTERNAME
$system = gwmi -class Win32_ComputerSystem -computername $hostname

$system.CurrentTimeZone = $tz_collection[$timezone]
$system.Put()

EOF

  source(ps_code)
end