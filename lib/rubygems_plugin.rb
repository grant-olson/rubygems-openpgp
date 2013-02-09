require 'rubygems/command_manager'
require 'rubygems/gem_openpgp'

Gem::CommandManager.instance.register_command :sign
Gem::CommandManager.instance.register_command :verify

i = Gem::CommandManager.instance[:install]
i.add_option("--verify",
             'Verifies a local gem that has been signed via OpenPGP.' +
             'This helps to ensure the gem has not been tampered with in transit.') do |value, options|
  Gem::OpenPGP.options[:verify] = true
end


i.add_option('--get-key', "If the key is not available, download it from a keyserver") do |key, options|
  Gem::OpenPGP.options[:get_key] = true
end

Gem.pre_install do |installer|
  begin
    if Gem::OpenPGP.options[:verify]
      Gem::OpenPGP.verify_gem(installer.gem,
                              Gem::OpenPGP.options[:get_key])
    end
  rescue Gem::OpenPGPException => ex
    installer.alert_error(ex.message)
    installer.terminate_interaction(1)
  end
end
