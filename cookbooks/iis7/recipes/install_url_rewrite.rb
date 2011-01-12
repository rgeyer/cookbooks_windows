#http://go.microsoft.com/?linkid=9722532
powershell "Installs IIS Url ReWrite ISAPI Module" do
  # Create the powershell script
  powershell_script = <<'EOF'
    $file = "rewrite_2.0_rtw_x64.msi"
    $url =  "http://download.microsoft.com/download/6/7/D/67D80164-7DD0-48AF-86E3-DE7A182D6815/rewrite_2.0_rtw_x64.msi"

    $curlPath = join-path $env:ProgramFiles "RightScale\\SandBox\\Git\\bin\\curl.exe"
    cmd /c "$curlPath" --max-time 120 -C - -O $url

    cmd /c $file /q

    rm $file
EOF

  source(powershell_script)
end
