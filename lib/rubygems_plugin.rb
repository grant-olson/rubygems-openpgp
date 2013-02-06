require 'rubygems/command_manager'

Gem::CommandManager.instance.register_command :sign
Gem::CommandManager.instance.register_command :verify
