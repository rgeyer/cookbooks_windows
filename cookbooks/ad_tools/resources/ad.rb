actions [ :join_domain, :unattended_dcpromo ]

attribute :admin_user, :kind_of => [String]
attribute :admin_domain, :kind_of => [String]
attribute :admin_pass, :kind_of => [String]
attribute :domain_name, :kind_of => [String]