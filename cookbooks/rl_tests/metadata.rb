maintainer       "Ryan J. Geyer"
maintainer_email "me@ryangeyer.com"
license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/Configures rl_tests"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

recipe "rl_tests::remote_recipe_setup", "Run on two instances which you want to use to test remote recipe"
recipe "rl_tests::remote_recipe_test", "Kicks off the whole test"
recipe "rl_tests::remote_recipe_ping", "Called by rl_tests::remote_recipe_test, then calls rl_tests::remote_recipe_pong"
recipe "rl_tests::remote_recipe_pong", "Called by rl_tests::remote_recipe_ping"