# TODO: When a machine becomes a domain controller, local users and groups are destroyed/ignored
# Need to get rightlink setup with the correct credentials to be able to continue running
# RightLink service - Needs AD service account?

ntds_dir = "C:\\Windows\\NTDS"

log "Hostname Set is #{@node[:mnt_utils_hostname_set]}"
log "DNS Set is #{@node[:mnt_utils_dns_set]}"
log "Default ad_bdc_init is #{@node[:ad_bdc_initialized]}"
log "Should run this script is #{@node[:mnt_utils_hostname_set] && @node[:mnt_utils_dns_set] && !@node[:ad_bdc_initialized]}"

if(@node[:mnt_utils_hostname_set] && @node[:mnt_utils_dns_set] && !@node[:ad_bdc_initialized])
  log "Entered if other scripts run"
  answers_file = "C:\\answers.txt"

  template answers_file do
    source "answers_bdc.txt.erb"
  end

  include_recipe "ad_tools::change_rightlink_service_account"

  ad_tools_ad "Promote Server To BDC" do
    action :unattended_dcpromo
  end

  right_link_tag "ad:domain=#{@node[:ad_tools][:domain_name]}"
  right_link_tag "ad:role=bdc"

  @node[:ad_bdc_initialized] = true
end