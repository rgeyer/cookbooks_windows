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

      $suffixAry = $env:SUFFIX_LIST.split(',')
      $NIC.DNSDomainSuffixSearchOrder($suffixAry)
    }
POWERSHELL_SCRIPT

    source(powershell_script)
  end
end