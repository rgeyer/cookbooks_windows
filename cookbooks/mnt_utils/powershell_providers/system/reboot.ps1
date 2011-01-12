$computer = get-content env:computername
$system = Get-WmiObject Win32_OperatingSystem -ComputerName $computer
$system.psbase.Scope.Options.EnablePrivileges = $true
#redirecting the output to $null to avoid script failure
$system.Reboot() > $null
Write-Output "Reboot signal sent!"