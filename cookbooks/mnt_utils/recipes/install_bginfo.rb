programFilesPath = "C:\\Program Files"
programFilesPath = "C:\\Program Files (x86)" if File.directory? "C:\\Program Files (x86)"

bginfo_path = "#{programFilesPath}\\BGInfo"

startup_file = "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\bginfo.bat"

template startup_file do
  source "bginfo.bat.erb"
  variables( :bginfo_path => bginfo_path )
end if !File.file? "#{bginfo_path}\\bginfo.bat"

directory bginfo_path do
  action :create
end if !File.directory? bginfo_path

powershell "Install BGInfo & add to startup items" do
  attachments_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files', 'install_bginfo'))
  parameters({
    'ATTACHMENTS_PATH' => attachments_path,
    'BGINFO_PATH' => bginfo_path
  })

  powershell_script = <<'EOF'
  Copy-Item "$env:ATTACHMENTS_PATH\*" "$env:BGINFO_PATH"
EOF

  source(powershell_script)

end