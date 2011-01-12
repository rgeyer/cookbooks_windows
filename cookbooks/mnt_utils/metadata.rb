maintainer "Ryan J. Geyer"
maintainer_email "rgeyer@its.jnj.com"
description "Random useful bits of code"
long_description "Random useful bits of code"
name "mnt_utils"
version "0.0.1"

provides "mnt_utils_set_dns(dns_list)"

recipe "mnt_utils::default", "Just for experimentation right now"
recipe "mnt_utils::set_dns", "Sets the DNS search list ot the provided CSV list"
recipe "mnt_utils::set_hostname", "Sets the system's hostname to match the nickname in the RightScale dashboard"
recipe "mnt_utils::install_bginfo", "Installs the BGInfo tool and sets it to run on each user login"
recipe "mnt_utils::helloworld", "A recipe which should always work, used as a control test"
recipe "mnt_utils::install_windowsupdates", "Downloads and installs all pending windows updates for the server"
recipe "mnt_utils::install_roles_and_features", "Installs one or many Windows 2008 roles and features using the mnt_utils::features_and_roles_list as input."
recipe "mnt_utils::reboot", "Reboots the system"
recipe "mnt_utils::install_scom_agent", "Installs the Microsoft System Center Operations Manager (SCOM) agent using settings from active directory"

attribute "mnt_utils/dns_list",
  :display_name => "A comma separated list of IPV4 addresses of DNS servers",
  :description => "A comma separated list of IPV4 addresses of DNS servers",
  :recipes => [ "mnt_utils::set_dns" ],
  :required => "required"

attribute "mnt_utils/rs_server_name",
  :display_name => "RightScale dashboard nickname",
  :description => "The RightScale dashboard nickname, this should be set to ENV:RS_SERVER_NAME",
  :recipes => [ "mnt_utils::set_hostname" ],
  :required => "required"

attribute "mnt_utils/features_and_roles_list",
  :display_name => "Windows 2008 Features & Roles",
  :description => "A CSV list of features and roles to install.  To view the list of available roles and features run 'servermanagercmd -query' on a Windows 2008 server instance",
  :recipes => [ "mnt_utils::install_roles_and_features" ],
  :default => ""

attribute "mnt_utils/rs_uuid",
  :display_name => "ENV RS_INSTANCE_UUID Value",
  :description => "Just set this to the RS_INSTANCE_UUID ENV value",
  :required => true,
  :recipes => ["mnt_utils::default"]

attribute "mnt_utils/scom_share_user",
  :display_name => "SCOM Share Username",
  :description => "The username of a user who has permissions to access the share which contains the SCOM agent.",
  :recipes => ["mnt_utils::install_scom_agent"],
  :required => true

attribute "mnt_utils/scom_share_pass",
  :display_name => "SCOM Share Password",
  :description => "The password of a user who has permissions to access the share which contains the SCOM agent.",
  :recipes => ["mnt_utils::install_scom_agent"],
  :required => true

attribute "mnt_utils/scom_share_unc",
  :display_name => "SCOM Share UNC Path",
  :description => "The UNC path of the share containing the SCOM agent installers.  Example: \\fileserver\SCOMShare",
  :recipes => ["mnt_utils::install_scom_agent"],
  :required => true

attribute "mnt_utils/scom_share_subdir",
  :display_name => "SCOM Share Subdirectory",
  :description => "The subdirectory of the share (if any) which contains the SCOM agent install files.  If your SCOM Share UNC Path is \\fileserver\SCOMShare, and this is InstallationFiles\Agent the full UNC path will be \\fileserver\SCOMShare\InstallationFiles\Agent",
  :recipes => ["mnt_utils::install_scom_agent"],
  :default => ""