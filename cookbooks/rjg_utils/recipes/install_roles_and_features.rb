
# A list of available roles & features by their names http://technet.microsoft.com/en-us/library/cc748918(WS.10).aspx

# TODO: Use node[:rjg_utils][:features_and_roles_list] only as an addition to node[:rjg_utils][:feature_and_roles_ary] which can be set
# from other recipes in order to specify their role and feature dependencies.  Only install from node[:rjg_utils][:feature_and_roles_ary]

include_recipe "rjg_utils::determine_architecture"

# This is not conditional assignment, this is an array join..  Maybe a different syntax would be a good idea to avoid confusion?
node[:rjg_utils][:features_and_roles_ary] = node[:rjg_utils][:features_and_roles_list].split(',') | node[:rjg_utils][:features_and_roles_ary]

if node[:platform_version].start_with? "5.2"
  # Win2k3 & Win2k3 RC2
  node[:rjg_utils][:features_and_roles_ary].each do |component|
    if !['snmp'].include? component
      raise "This recipe does not know how to install (#{component}) on Windows 2003."
    else
      answer_path = ::File.join(ENV['TMP'], "#{component}_answers.txt")
      if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
        cookbook_file answer_path do
          source "win2k3_components/#{component}.txt"
        end
      else
        remote_file answer_path do
          source "win2k3_components/#{component}.txt"
        end
      end

      powershell "Install component #{component} from answer file in Windows 2003" do
        parameters({'SYSOCMGR_PATH' => ::File.join(node[:rjg_utils][:system32_dir], "sysocmgr.exe"), 'ANSWERS' => answer_path})
        powershell_script = <<'EOF'
        & $env:SYSOCMGR_PATH /i:$env:WINDIR\inf\sysoc.inf /u:$env:ANSWERS /r /q

EOF
        source(powershell_script)
      end
    end
  end

else
  # Win2k8 & Win2k8 RC2

  powershell "Install the CSV list of windows features and roles in Windows 2008" do
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
end