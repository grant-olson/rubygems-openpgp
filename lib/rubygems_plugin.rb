require 'rubygems/gem_openpgp'
require 'rubygems/openpgp/sign_plugins'
require 'rubygems/openpgp/verify_plugins'
require 'rubygems/openpgp/gpg_options'

# Add gpg forwarding options
[:sign, :verify, :build, :install].each do |cmd_name|
  cmd = Gem::CommandManager.instance[cmd_name]
  Gem::OpenPGP.add_gpg_options(cmd)
end

