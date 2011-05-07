maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description "Random useful bits of code"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
name "rjg_utils"
version "0.0.1"

provides "rjg_utils_set_dns(dns_list)"

recipe "rjg_utils::default", "Adds a powershell function library to the C:\\ drive for use by other recipes"
recipe "rjg_utils::set_dns", "Sets the DNS search list ot the provided CSV list"
recipe "rjg_utils::set_hostname", "Sets the system's hostname to match the nickname in the RightScale dashboard"
recipe "rjg_utils::install_bginfo", "Installs the BGInfo tool and sets it to run on each user login"
recipe "rjg_utils::helloworld", "A recipe which should always work, used as a control test"
recipe "rjg_utils::install_windowsupdates", "Downloads and installs all pending windows updates for the server"
recipe "rjg_utils::install_roles_and_features", "Installs one or many Windows 2008 roles and features using the rjg_utils::features_and_roles_list as input."
recipe "rjg_utils::reboot", "Reboots the system"
recipe "rjg_utils::install_scom_agent", "Installs the Microsoft System Center Operations Manager (SCOM) agent using settings from active directory"
recipe "rjg_utils::determine_architecture", "Sets some node attributes based on the processor architecture of the node (x86 or x64)"
recipe "rjg_utils::create_users", "Creates or updates a set of users defined in a yaml file stored in an S3 bucket"

attribute "rjg_utils/dns_list",
  :display_name => "DNS Server List",
  :description => "A comma separated list of IPV4 addresses of DNS servers",
  :recipes => [ "rjg_utils::set_dns" ],
  :required => "required"

attribute "rjg_utils/dns_suffix_list",
  :display_name => "DNS Suffix List",
  :description => "A comma separated list of DNS suffixes",
  :recipes => [ "rjg_utils::set_dns" ],
  :required => "required"

attribute "rjg_utils/hostname",
  :display_name => "Hostname",
  :description => "The desired hostname for the instance",
  :recipes => [ "rjg_utils::set_hostname","rjg_utils::create_users"],
  :required => "required"

attribute "rjg_utils/features_and_roles_list",
  :display_name => "Windows 2008 Features & Roles",
  :description => "A CSV list of features and roles to install.  To view the list of available roles and features run 'servermanagercmd -query' on a Windows 2008 server instance",
  :recipes => [ "rjg_utils::install_roles_and_features" ],
  :default => ""

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

attribute "rjg_utils/users_s3_bucket",
  :display_name => "Users S3 bucket",
  :description => "The S3 bucket containing a yaml file describing local users to create",
  :recipes => ["rjg_utils::create_users"],
  :required => "required"

attribute "rjg_utils/users_file",
  :display_name => "Users YAML File",
  :description => "A yaml file containing an array of objects describing local users to be created on the system.",
  :recipes => ["rjg_utils::create_users"],
  :required => "required"

attribute "rjg_utils/users_access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rjg_utils::create_users"],
  :required => "required"

attribute "rjg_utils/users_secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rjg_utils::create_users"],
  :required => "required"

attribute "rjg_utils/custom_bginfo",
  :display_name => "Custom BGInfo?",
  :description => "A boolean indicating if a zip file containing a custom bginfo configuration should be download from S3.  If true rjg_utils/bginfo_s3_file and rjg_utils/bginfo_s3_bucket must be set",
  :recipes => ["rjg_utils::install_bginfo"],
  :choice => ["true", "false"],
  :default => "false"

attribute "rjg_utils/bginfo_s3_file",
  :display_name => "BGInfo Zip S3 file",
  :description => "The full S3 key to a zip file containing a logon.bgi file, and any files which it depends upon (I.E. like images)",
  :recipes => ["rjg_utils::install_bginfo"],
  :required => "optional"

attribute "rjg_utils/bginfo_s3_bucket",
  :display_name => "BGInfo Zip S3 bucket",
  :description => "The S3 bucket containing rjg_utils/bginfo_s3_file",
  :recipes => ["rjg_utils::install_bginfo"],
  :required => "optional"

attribute "aws/access_key_id",
  :display_name => "Access Key Id",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve you access identifiers. Ex: 1JHQQ4KVEVM02KVEVM02",
  :recipes => ["rjg_utils::install_bginfo"],
  :required => "required"

attribute "aws/secret_access_key",
  :display_name => "Secret Access Key",
  :description => "This is an Amazon credential. Log in to your AWS account at aws.amazon.com to retrieve your access identifiers. Ex: XVdxPgOM4auGcMlPz61IZGotpr9LzzI07tT8s2Ws",
  :recipes => ["rjg_utils::install_bginfo"],
  :required => "required"