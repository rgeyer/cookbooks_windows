rjg_utils_set_dns do
  dns_list node[:rjg_utils][:dns_list]
  dns_suffix_list node[:rjg_utils][:dns_suffix_list]
end

node[:rjg_utils_dns_set] = true