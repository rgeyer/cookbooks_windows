$service_name = Get-NewResource service_name
$service_account_user = Get-NewResource service_account_user
$service_account_pass = Get-NewResource service_account_pass
$restart_service = Get-NewResource restart_service

$computer = get-content env:computername

Write-Output("Service name is $service_name")
Write-Output("restart service is $restart_service")

# The documentation says that "NULL" for StartName and StartPassword will result in Local System, but
# it looks like you have to be explicit about it.
# http://msdn.microsoft.com/en-us/library/aa384901(v=VS.85).aspx
if ( (!$service_account_user) -and (!$service_account_pass) ) {
  $service_account_user = "LocalSystem"
  $service_account_pass = $null
  Write-Output("Changed from blank")
} else { Write-Output("The user creds remained blank") }

Write-Output("Past the conditional statement")

$service="name='$service_name'"

Write-Output("The service WMI search is $service")

$svc=Get-WmiObject win32_service -computer $computer -filter $service

Write-Output("Service object is $svc")

#if ($restart_service.ToLower() -eq "true") { $svc.StopService() }
if ($svc) {
  $inParams = $svc.psbase.getMethodParameters("Change")
  $inParams["StartName"] = $service_account_user
  $inParams["StartPassword"] = $service_account_pass
  $svc.invokeMethod("Change",$inParams,$null)
}
else { Write-Output("I no can getting the svc") }
#if ($restart_service.ToLower() -eq "true") { $svc.StartService() }