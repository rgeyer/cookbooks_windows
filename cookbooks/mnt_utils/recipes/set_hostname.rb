unless node[:mnt_utils_hostname_set]
  mnt_utils_system "Reboot System" do
    action :nothing
  end

  powershell "Set the computer hostname to the same as the RightScale nickname" do
    parameters({'RS_SERVER_NAME' => node[:mnt_utils][:rs_server_name]})

    powershell_script = <<'EOF'
# The regex cleans things up so all is well.
$NewComputerName = $env:RS_SERVER_NAME -replace "[^0-9a-zA-Z_]","-"
$NewComputerName = $NewComputerName.ToUpper()
# Shorten it to 16 characters
if($NewComputerName.length -gt 16) {
  $NewComputerName = $NewComputerName.SubString(0, 15)
}

$CurrentComputerName = $env:COMPUTERNAME.ToUpper()

write-output("About to compare hostnames $($NewComputerName) == $($CurrentComputerName)")

if( $NewComputerName.CompareTo($CurrentComputerName) -eq 0 ) {
  write-output("The hostname was already set to $($NewComputerName), hostname was not changed")
  set-chefnode mnt_utils_hostname_reboot -BooleanValue $false
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

  set-chefnode mnt_utils_hostname_reboot -BooleanValue $true
  set-chefnode mnt_utils_hostname_set -BooleanValue $true
}
EOF

    source(powershell_script)
    notifies :reboot, resources(:mnt_utils_system => "Reboot System")
  end

  ruby_block "Set done and check for reboot only after powershell resource is run" do
    block do
      if node[:mnt_utils_hostname_reboot]
        node[:mnt_utils_hostname_reboot] = false
      end
    end
  end
end