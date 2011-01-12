maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures iis7"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
name "iis7"
version          "0.0.1"

recipe "iis7::default", "This don't do nuthin'"
recipe "iis7::install_url_rewrite", "Installs the rewrite ISAPI extension for IIS7"