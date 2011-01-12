mnt_utils_set_dns do
  dns_list node[:mnt_utils][:dns_list]
end

node[:mnt_utils_dns_set] = true