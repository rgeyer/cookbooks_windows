
# A list of available roles & features by their names http://technet.microsoft.com/en-us/library/cc748918(WS.10).aspx

include_recipe "rjg_utils::determine_architecture"

powershell "Installs the CSV list of windows features and roles" do
  powershell_script = <<'EOF'
  $roleAndFeatureAry = get-chefnode rjg_utils,features_and_roles_list
  $binpath = Get-ChefNode rjg_utils, system32_dir

  write-output("The role and feature list was $($roleAndFeatureAry)")
  $argList = @("-install")
  $argList += $roleAndFeatureAry.Split(',')
  $argList += @("-logPath","C:\roleAndFeatureInstall.log")
#  $roleAndFeatureAry.Split(',') | foreach-object {
#    write-output ("Installing role or feature $($_)")
    start-process -FilePath "$binpath\ServerManagerCmd.exe" -ArgumentList $argList -PassThru -Wait
    (get-content -Path C:\roleAndFeatureInstall.log)[-1]
    rm C:\roleAndFeatureInstall.log
#  }
EOF
  source(powershell_script)
end unless node[:rjg_utils][:features_and_roles_list] == ""