log "Hello World"

log "This here is #{node[:mnt_utils][:rs_uuid]}"

server_collection "all_servers" do
  tags [ "ad:role=member" ]
end

ruby_block "tag debugz" do
  block do
    node[:server_collection]["all_servers"].each do |server_key|
      Chef::Log.info "The server looks like this #{server_key.inspect}"
    end
  end
end

powershell "Mount a drive - test" do
  powershell = <<'EOF'
(New-Object -ComObject WScript.Network).MapNetworkDrive("X:", "\\mntutladm01\InstallMedia")
#cmd /c net use X: \\mntutladm01\InstallMedia
EOF
  source(powershell)
end



#node[:server_collection]["all_servers"].each do |server|
#  Chef::Log.info "ID is #{server}"
#end