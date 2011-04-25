# TODO: This doesn't really work yet, and it might just make more sense for us to use
# the discovery wizard rather than trying to include the install on every new machine

powershell "Install SCOM Agent" do
  powershell =<<'EOF'
$share_unc = get-chefnode rjg_utils, scom_share_unc
$agent_dir_path = get-chefnode rjg_utils, scom_share_subdir
$user = get-chefnode rjg_utils, scom_share_user
$pass = get-chefnode rjg_utils, scom_share_pass

$net_obj = $(New-Object -ComObject WScript.Network)
$net_obj.MapNetworkDrive("X:", $share_unc, $false, $user, $pass)

$full_exe_path = "X:\"
if(![system.string]::IsNullOrEmpty($agent_dir_path)) {
  $full_exe_path += $agent_dir_path
}
$full_exe_path += "$env:PROCESSOR_ARCHITECTURE\MOMAgent.msi"

cmd /c "$full_exe_path" /qn USE_SETTINGS_FROM_AD=1 USE_MANUALLY_SPECIFIED_SETTINGS=0

$net_obj.RemoveNetworkDrive("X:")
EOF
end if node[:ad_tools_joined_domain]