powershell "Install Microsoft SQL Enterprise Server 2008" do
  powershell_script = <<'EOF'
  # Pay no attention to how we get the ISO downloaded and mounted for now
  E:\Setup.exe /q /ACTION=Install `
    /FEATURES=SQL,RS `
    /InstanceID=<MYINST> `
    /IACCEPTSQLSERVERLICENSETERMS
EOF

  source(powershell_script)
end