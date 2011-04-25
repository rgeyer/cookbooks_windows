# Handy DCPROMO answer file templates http://support.microsoft.com/kb/947034

include_recipe "rjg_utils::determine_architecture"

answers_file = "C:\\answers.txt"

template answers_file do
  source "answers_demote.txt.erb"
end

ad_tools_ad "Demote server from DC role" do
  answers_file answers_file
  action :unattended_dcpromo
end

right_link_tag "ad:*" do
  action :remove
end

@node[:ad_bdc_initialized] = false