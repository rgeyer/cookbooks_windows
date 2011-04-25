maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description "Random useful bits of code"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
name "rjg_utils"
version "0.0.1"

provides "rjg_utils_set_dns(dns_list)"

recipe "rjg_utils::default", "Just for experimentation right now"
recipe "rjg_utils::set_dns", "Sets the DNS search list ot the provided CSV list"
recipe "rjg_utils::set_hostname", "Sets the system's hostname to match the nickname in the RightScale dashboard"
recipe "rjg_utils::install_bginfo", "Installs the BGInfo tool and sets it to run on each user login"
recipe "rjg_utils::helloworld", "A recipe which should always work, used as a control test"
recipe "rjg_utils::install_windowsupdates", "Downloads and installs all pending windows updates for the server"
recipe "rjg_utils::install_roles_and_features", "Installs one or many Windows 2008 roles and features using the rjg_utils::features_and_roles_list as input."
recipe "rjg_utils::reboot", "Reboots the system"
recipe "rjg_utils::install_scom_agent", "Installs the Microsoft System Center Operations Manager (SCOM) agent using settings from active directory"
recipe "rjg_utils::determine_architecture", "Sets some node attributes based on the processor architecture of the node (x86 or x64)"

attribute "rjg_utils/dns_list",
  :display_name => "A comma separated list of IPV4 addresses of DNS servers",
  :description => "A comma separated list of IPV4 addresses of DNS servers",
  :recipes => [ "rjg_utils::set_dns" ],
  :required => "required"

attribute "rjg_utils/hostname",
  :display_name => "Hostname",
  :description => "The desired hostname for the instance",
  :recipes => [ "rjg_utils::set_hostname" ],
  :required => "required"

attribute "rjg_utils/features_and_roles_list",
  :display_name => "Windows 2008 Features & Roles",
  :description => "A CSV list of features and roles to install.  To view the list of available roles and features run 'servermanagercmd -query' on a Windows 2008 server instance",
  :recipes => [ "rjg_utils::install_roles_and_features" ],
  :default => ""

attribute "rjg_utils/rs_uuid",
  :display_name => "ENV RS_INSTANCE_UUID Value",
  :description => "Just set this to the RS_INSTANCE_UUID ENV value",
  :required => true,
  :recipes => ["rjg_utils::default"]

attribute "rjg_utils/scom_share_user",
  :display_name => "SCOM Share Username",
  :description => "The username of a user who has permissions to access the share which contains the SCOM agent.",
  :recipes => ["rjg_utils::install_scom_agent"],
  :required => true

attribute "rjg_utils/scom_share_pass",
  :display_name => "SCOM Share Password",
  :description => "The password of a user who has permissions to access the share which contains the SCOM agent.",
  :recipes => ["rjg_utils::install_scom_agent"],
  :required => true

attribute "rjg_utils/scom_share_unc",
  :display_name => "SCOM Share UNC Path",
  :description => "The UNC path of the share containing the SCOM agent installers.  Example: \\fileserver\SCOMShare",
  :recipes => ["rjg_utils::install_scom_agent"],
  :required => true

attribute "rjg_utils/scom_share_subdir",
  :display_name => "SCOM Share Subdirectory",
  :description => "The subdirectory of the share (if any) which contains the SCOM agent install files.  If your SCOM Share UNC Path is \\fileserver\SCOMShare, and this is InstallationFiles\Agent the full UNC path will be \\fileserver\SCOMShare\InstallationFiles\Agent",
  :recipes => ["rjg_utils::install_scom_agent"],
  :default => ""