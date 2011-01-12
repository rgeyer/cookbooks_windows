#begin
require 'rubygems'
require 'rest_connection'

domain_controllers = Tag.search('ec2_instance', ["dns:domain=#{node[:ad_tools][:domain_name]}"])
private_ips = []
domain_controllers.each do |s|
  private_ips += [Server.find(s["href"]).settings["private_ip_address"]]
end

node[:ad_tools_dns_list] = private_ips.join(',')
Chef::Log.info("This is the dns list #{node[:ad_tools_dns_list]}")

mnt_utils_set_dns do
  dns_list node[:ad_tools_dns_list]
end

node[:ad_tools_dns_set] = true
#rescue LoadError
#  raise "The rest_connection ruby gem is required, but not available.  DNS was not set.  Please run a recipe which installs rest_connection, such as utils::install_rest_connection_gem from - https://github.com/rgeyer/cookbooks"
#end