require 'rubygems/command_manager'

Gem::CommandManager.instance.register_command :sign
Gem::CommandManager.instance.register_command :verify
#Gem::CommandManager.instance.register_command :vinstall
#Gem::CommandManager.instance.register_command :sbuild
