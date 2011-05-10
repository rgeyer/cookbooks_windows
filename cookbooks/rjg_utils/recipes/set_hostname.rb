unless node[:rjg_utils_hostname_set]
  rjg_utils_system "Reboot System" do
    action :nothing
  end

  powershell "Set the computer hostname and workgroup name" do
    parameters({
      'HOSTNAME' => node[:rjg_utils][:hostname],
      'WORKGROUP' => node[:rjg_utils][:workgroup]
    })

    powershell_script = <<'EOF'
# The regex cleans things up so all is well.
$NewComputerName = $env:HOSTNAME -replace "[^0-9a-zA-Z_]","-"
$NewComputerName = $NewComputerName.ToUpper()
# Shorten it to 16 characters
if($NewComputerName.length -gt 16) {
  $NewComputerName = $NewComputerName.SubString(0, 15)
}

$CurrentComputerName = $env:COMPUTERNAME.ToUpper()

write-output("About to compare hostnames $($NewComputerName) == $($CurrentComputerName)")

if( $NewComputerName.CompareTo($CurrentComputerName) -eq 0 ) {
  write-output("The hostname was already set to $($NewComputerName), hostname was not changed")
  set-chefnode rjg_utils_hostname_reboot -BooleanValue $false
} else {
  $programFilesPath = "C:\Program Files"
  echo "The progam files dir is set to $programFilesPath"
  $ec2ConfigFile = "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml"
  [xml]$ec2configXml = get-content $ec2ConfigFile
  $compNameNode = $ec2ConfigXml.SelectSingleNode("/Ec2ConfigurationSettings/Plugins/Plugin[Name='Ec2SetComputerName']")
  $compNameNode.State = 'Disabled'
  if (Test-Path "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml.bak") {
    del "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml.bak"
  }
  move $ec2ConfigFile "$programFilesPath\Amazon\Ec2ConfigService\Settings\config.xml.bak"
  $ec2ConfigXml.save($ec2ConfigFile)

  $computerinfo = Get-WmiObject -class win32_computersystem
  $computerinfo.Rename($NewComputerName)
  $computerinfo.JoinDomainOrWorkgroup($env:WORKGROUP)

  set-chefnode rjg_utils_hostname_reboot -BooleanValue $true
  set-chefnode rjg_utils_hostname_set -BooleanValue $true
}
EOF

    source(powershell_script)
    notifies :reboot, resources(:rjg_utils_system => "Reboot System")
  end
end