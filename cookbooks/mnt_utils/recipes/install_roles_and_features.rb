include_recipe "mnt_utils::determine_architecture"

powershell "Installs the CSV list of windows features and roles" do
  powershell_script = <<'EOF'
  $roleAndFeatureAry = get-chefnode mnt_utils,features_and_roles_list
  $binpath = Get-ChefNode mnt_utils, system32_dir

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
end unless node[:mnt_utils][:features_and_roles_list] == ""