if(node[:mnt_utils_hostname_set] && node[:ad_tools_dns_set] && !node[:ad_tools_joined_domain])
  Chef::Log.info("The hostname has been set, the DNS has been set, and now we can join the domain.")
  # 1. Retrieve inputs
  domain   = node[:ad_tools][:domain_name]
  admin_username = node[:ad_tools][:admin_user]
  admin_password = node[:ad_tools][:admin_pass]

  Chef::Log.info "domain:         #{domain}"
  Chef::Log.info "admin username: #{admin_username}"

  # 3. Join domain
  ad_tools_ad domain do
    admin_user admin_username
    admin_pass admin_password
    action :join_domain
  end

  right_link_tag "ad:domain=#{node[:ad_tools][:domain_name]}"
  right_link_tag "ad:role=member"

  node[:ad_tools_joined_domain] = true

  mnt_utils_system "Reboot System" do
    action :reboot
  end
end