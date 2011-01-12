define :rs_sandbox_exec, :code => "" do
  powershell_script = <<'EOF'
# Make sure we know where to find the sandbox
cmd /c LocateSandBox.bat

# Modify the path environment variable for just this powershell execution, so we can find
# things like gem, and ruby..
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$env:RS_SANDBOX_HOME\Ruby\bin;$env:RS_SANDBOX_HOME\bin\windows;$env:RS_SANDBOX_HOME\right_link\scripts\windows")

EOF

  powershell_script += params[:code]

  powershell params[:name] do
    source(powershell_script)
  end
end