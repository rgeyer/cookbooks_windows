programFilesPath = "C:\\Program Files"

bginfo_path = "#{programFilesPath}\\BGInfo"
startup_file = "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\bginfo.bat"
attachments_path = ::File.expand_path(::File.join(::File.dirname(__FILE__), '..', 'files', 'install_bginfo'))
login_bgi_file = ::File.join(bginfo_path, 'logon.bgi')

#bginfo_dl_uri = "http://download.sysinternals.com/Files/BgInfo.zip"

template startup_file do
  source "bginfo.bat.erb"
  variables( :bginfo_path => bginfo_path )
end if !File.file? "#{bginfo_path}\\bginfo.bat"

directory bginfo_path do
  action :create
end if !File.directory? bginfo_path

powershell "Install BGInfo & add to startup items" do
  parameters({
    'BGINFO_ZIP' => ::File.join(attachments_path, 'BGInfo.zip'),
    'BGINFO_PATH' => bginfo_path
  })

  powershell_script = <<'EOF'
  #Copy-Item "$env:ATTACHMENTS_PATH\*" "$env:BGINFO_PATH"
  $command='cmd /c 7z x -y "'+$env:BGINFO_ZIP+'" -o"'+$env:BGINFO_PATH+'""'
  $command_ouput=invoke-expression $command
  if (!($command_ouput -match 'Everything is Ok'))
  {
      echo $command_ouput
      Write-Error "Error: Unzipping failed"
      exit 144
  }
EOF

  source(powershell_script)
end

if(node[:rjg_utils][:custom_bginfo] == "true")
  rjg_aws_s3 "Get the custom bg_info configuration zipfile" do
    access_key_id node[:aws][:access_key_id]
    secret_access_key node[:aws][:secret_access_key]
    s3_file node[:rjg_utils][:bginfo_s3_file]
    s3_bucket node[:rjg_utils][:bginfo_s3_bucket]
    file_path login_bgi_file
    action :get
  end
else

  powershell "Copy the default bginfo configuration to disk" do
    parameters({ 'ATTACHMENTS_PATH' => attachments_path, 'LOGIN_BGI_PATH' => login_bgi_file })
    powershell_script = <<'EOF'
Copy-Item "$env:ATTACHMENTS_PATH\login.bgi" "$env:LOGIN_BGI_PATH"
EOF
    source (powershell_script)
  end

end