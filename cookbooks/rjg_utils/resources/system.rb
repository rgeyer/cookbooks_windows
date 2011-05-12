# TODO: add a conditional_reboot action that will check a particular node attribute for true before rebooting.

actions [:reboot, :conditional_reboot]

attribute :node_attribute, :kind_of => [String]