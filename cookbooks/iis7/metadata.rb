maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          "All rights reserved"
description      "Installs/Configures iis7"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
name "iis7"
version          "0.0.1"

recipe "iis7::default", "This don't do nuthin'"
recipe "iis7::install_url_rewrite", "Installs the rewrite ISAPI extension for IIS7"
recipe "iis7::enable_sessionstate_server", "Configures this server as an ASP.NET shared session state server"