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

define :rjg_utils_set_dns, :dns_list => nil, :dns_suffix_list => nil do
  powershell "Sets the DNS search list to the provided CSV list" do
    parameters({'DNS_LIST' => params[:dns_list], 'SUFFIX_LIST' => params[:suffix_list]})

    powershell_script = <<'POWERSHELL_SCRIPT'
    $NICs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE"
    foreach($NIC in $NICs) {
      # We keep the last one in the list since that's the one Ec2 gave us and we don't wanna nuke it
      [array]$dnsAry = @($NIC.DNSServerSearchOrder[-1])
      $dnsAry = $env:DNS_LIST.split(',') + $dnsAry
      $NIC.SetDNSServerSearchOrder($dnsAry)
    }
    # Setting the suffixes is a static method call
    invoke-wmimethod -Class win32_networkadapterconfiguration -Name setDNSSuffixSearchOrder -ArgumentList @($env:SUFFIX_LIST.split(',')), $null
POWERSHELL_SCRIPT

    source(powershell_script)
  end
end