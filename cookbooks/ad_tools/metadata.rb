maintainer "Ryan J. Geyer"
maintainer_email "rgeyer@its.jnj.com"
description "Configures Windows 2008 Servers to act as primary or backup domian controllers.  Provides some other useful tools for domain controllers as well"
long_description "Configures Windows 2008 Servers to act as primary or backup domian controllers.  Provides some other useful tools for domain controllers as well"
name "ad_tools"
version "0.0.1"

recipe "ad_tools::initialize_bdc", "Runs dcpromo with appropriate answers to create a backup or slave domain controller for the specified domain"
recipe "ad_tools::demote_dc", "Removes the domain controller from the forest and uninstalls the AD binaries"
recipe "ad_tools::join_domain", "Adds the node to an existing domain"
recipe "ad_tools::reset_is_bdc", "Debug script so I can test things relating to active directory."
recipe "ad_tools::reset_joined_domain", "Debug script so I can test things relating to active directory"
recipe "ad_tools::change_rightlink_service_account", "Changes the service account for both RightScale services to Local System"
recipe "ad_tools::set_dns", "Sets the dns server(s) to the internal IP's of the domain controllers.  Assumes that the domain controllers, and the server this recipe is run on are in the same EC2 cloud."

depends "utilities"
depends "mnt_utils"

attribute "utilities/admin_password",
  :display_name => "New administrator password",
  :description => "New administrator password",
  :recipes => [ "ad_tools::demote_dc"],
  :required => "required"

attribute "ad_tools/admin_user",
  :display_name => "Domain Administrator Username",
  :description => "Domain Administratoru Username",
  :recipes => [
    "ad_tools::initialize_bdc",
    "ad_tools::join_domain"
  ],
  :required => "required"

attribute "ad_tools/admin_domain",
  :display_name => "Domain Administrator Domain",
  :description => "Domain Administrator Domain.  The <domain> part of <domain>\<username> for an active directory username",
  :recipes => [
    "ad_tools::initialize_bdc",
    "ad_tools::join_domain"
  ],
  :required => "required"

attribute "ad_tools/admin_pass",
  :display_name => "Domain Administrator Password",
  :description => "Domain Administrator Password",
  :recipes => [
    "ad_tools::initialize_bdc",
    "ad_tools::join_domain"
  ],
  :required => "required"

attribute "ad_tools/domain_name",
  :display_name => "FQDN of new or replicated active directory domain",
  :description => "FQDN of new or replicated active directory domain",
  :recipes => [
    "ad_tools::initialize_bdc",
    "ad_tools::demote_dc",
    "ad_tools::join_domain",
    "ad_tools::set_dns"
  ],
  :required => "required"