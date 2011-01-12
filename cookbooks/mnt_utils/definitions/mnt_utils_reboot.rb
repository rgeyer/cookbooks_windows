define :mnt_utils_reboot, :foo => nil do

  powershell "Reboots the system" do

    # Create the powershell script
    powershell_script = <<'POWERSHELL_SCRIPT'
    $computer = get-content env:computername
    $system = Get-WmiObject Win32_OperatingSystem -ComputerName $computer
    $system.psbase.Scope.Options.EnablePrivileges = $true
    #redirecting the output to $null to avoid script failure
    $system.Reboot() > $null
    Write-Output "Reboot signal sent!"
POWERSHELL_SCRIPT

    source(powershell_script)
  end

end