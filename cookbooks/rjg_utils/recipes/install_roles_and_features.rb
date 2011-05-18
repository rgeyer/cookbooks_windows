
# A list of available roles & features by their names http://technet.microsoft.com/en-us/library/cc748918(WS.10).aspx

# TODO: Use node[:rjg_utils][:features_and_roles_list] only as an addition to node[:rjg_utils][:feature_and_roles_ary] which can be set
# from other recipes in order to specify their role and feature dependencies.  Only install from node[:rjg_utils][:feature_and_roles_ary]

include_recipe "rjg_utils::determine_architecture"

# This is not conditional assignment, this is an array join..  Maybe a different syntax would be a good idea to avoid confusion?
node[:rjg_utils][:features_and_roles_ary] = node[:rjg_utils][:features_and_roles_list].split(',') | node[:rjg_utils][:features_and_roles_ary]

powershell "Installs the CSV list of windows features and roles" do
  powershell_script = <<'EOF'
  $roleAndFeatureAry = get-chefnode rjg_utils,features_and_roles_ary
  $binpath = Get-ChefNode rjg_utils, system32_dir

  write-output("The role and feature list was $($roleAndFeatureAry)")
  $argList = @("-install")
  $argList += $roleAndFeatureAry
  $argList += @("-logPath","C:\roleAndFeatureInstall.log")
#  $roleAndFeatureAry.Split(',') | foreach-object {
#    write-output ("Installing role or feature $($_)")
    start-process -FilePath "$binpath\ServerManagerCmd.exe" -ArgumentList $argList -PassThru -Wait
    (get-content -Path C:\roleAndFeatureInstall.log)[-1]
    rm C:\roleAndFeatureInstall.log
#  }
EOF
  source(powershell_script)
end