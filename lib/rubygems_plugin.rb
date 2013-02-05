require 'rubygems/command_manager'
require 'rubygems/gem_openpgp'
require 'rubygems/gem_openpgp/version'

Gem::CommandManager.instance.register_command :sign
Gem::CommandManager.instance.register_command :verify

Gem.pre_install do |installer|
  installer.say(Gem::OpenPGP.verify_gem(installer.gem))
end
