$admin_user = Get-NewResource admin_user
$admin_domain = Get-NewResource admin_domain
$admin_pass = Get-NewResource admin_pass
$domain_name = Get-NewResource domain_name

$ansStream = [System.IO.StreamWriter] "C:\answers.txt"
$ansStream.WriteLine("[DCINSTALL]")
$ansStream.WriteLine("UserName=$admin_user")
$ansStream.WriteLine("UserDomain=$admin_domain")
$ansStream.WriteLine("Password=$admin_pass")
$ansStream.WriteLine("ReplicaDomainDNSName=$domain_name")
$ansStream.WriteLine("ReplicaOrNewDomain=Replica")
$ansStream.WriteLine("InstallDNS=Yes")
$ansStream.WriteLine("ConfirmGC=Yes")
$ansStream.WriteLine("SafeModeAdminPassword=$admin_pass")
$ansStream.WriteLine("RebootOnCompletion=Yes")
$ansStream.close()
Write-Output("***Starting the DCPromo.exe process")
start-process -FilePath "$env:windir\Sysnative\dcpromo.exe" -ArgumentList /answer:C:\answers.txt -Wait
del "C:\answers.txt"