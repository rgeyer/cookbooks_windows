#
# Cookbook Name:: rjg_utils
# Recipe:: install_bginfo
#
#  Copyright 2011 Ryan J. Geyer
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

include_recipe "utilities::install_7zip"
# In RightScale you need to actually include rjg_aws::default in the boot phase or the attributes won't be set
include_recipe "aws::default"

programFilesPath = "C:\\Program Files"
bginfo_path = "#{programFilesPath}\\BGInfo"
install_zip = ::File.join(ENV['TMP'], "BGInfo.zip")
custom_logon_bgi_zip = ::File.join(bginfo_path, 'BGInfo.zip')
logon_bgi_file = ::File.join(bginfo_path, 'logon.bgi')

if node[:platform_version].start_with? "5.2"
  # Win2k3 & Win2k3 RC2
  startup_file = "C:\\Documents and Settings\\All Users\\Start Menu\\Programs\\Startup\\bginfo.bat"
else
  # Win2k8 & Win2k8 RC2
  startup_file = "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\bginfo.bat"
end

#bginfo_dl_uri = "http://download.sysinternals.com/Files/BgInfo.zip"
if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
  cookbook_file install_zip do
    source "install_bginfo/BgInfo.zip"
  end
else
  remote_file install_zip do
    source "install_bginfo/BgInfo.zip"
  end
end

template startup_file do
  source "bginfo.bat.erb"
  variables( :bginfo_path => bginfo_path )
end if !File.file? "#{bginfo_path}\\bginfo.bat"

directory bginfo_path do
  action :create
end if !File.directory? bginfo_path

powershell "Install BGInfo & add to startup items" do
  parameters({
    'BGINFO_ZIP' => install_zip,
    'BGINFO_PATH' => bginfo_path
  })

  powershell_script = <<'EOF'
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
  aws_s3 "Get the custom bg_info configuration zipfile" do
    access_key_id node[:aws][:access_key_id]
    secret_access_key node[:aws][:secret_access_key]
    s3_file node[:rjg_utils][:bginfo_s3_file]
    s3_bucket node[:rjg_utils][:bginfo_s3_bucket]
    download_dir bginfo_path
    action :get
  end

  powershell "Unzipping bginfo configuration to disk - #{custom_logon_bgi_zip}" do
    parameters({ 'BGINFO_PATH' => bginfo_path, 'BGINFO_ZIP' => custom_logon_bgi_zip })
    powershell_script = <<'EOF'
$command='cmd /c 7z x -y "'+$env:BGINFO_ZIP+'" -o"'+$env:BGINFO_PATH+'""'
$command_ouput=invoke-expression $command
if (!($command_ouput -match 'Everything is Ok'))
{
    echo $command_ouput
    Write-Error "Error: Unzipping failed"
    exit 144
}
EOF
    source (powershell_script)
  end
else
  if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('0.9.0')
    cookbook_file logon_bgi_file do
      source "install_bginfo/logon.bgi"
    end
  else
    remote_file logon_bgi_file do
      source "install_bginfo/logon.bgi"
    end
  end
end