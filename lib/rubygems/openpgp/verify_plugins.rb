require 'rubygems/command_manager'
require 'rubygems/gem_openpgp'

Gem::CommandManager.instance.register_command :verify

# gem install hooks
i = Gem::CommandManager.instance[:install]
i.add_option("--verify",
             'Verifies a local gem that has been signed via OpenPGP.' +
             'This helps to ensure the gem has not been tampered with in transit.') do |value, options|
  Gem::OpenPGP.options[:verify] = true
end

i.add_option("--no-verify",
             "Don't verify a gem, even if --verify has previously been specified") do |value, options|
  Gem::OpenPGP.options[:no_verify] = true
end

i = Gem::CommandManager.instance[:install]
i.add_option("--trust",
             'Enforce gnupg trust settings.  Only install if trusted.') do |value, options|
  Gem::OpenPGP.options[:trust] = true
end

i.add_option("--no-trust",
             "Ignoure gnupg trust settings,  even if --trust has previously been specified") do |value, options|
  Gem::OpenPGP.options[:no_trust] = true
end

i.add_option('--get-key', "If the key is not available, download it from a keyserver") do |key, options|
  Gem::OpenPGP.options[:get_key] = true
end

Gem.pre_install do |installer|
  begin
    # --no-verify overrides --verify
    if Gem::OpenPGP.options[:verify] && !Gem::OpenPGP.options[:no_verify]
      Gem::OpenPGP.verify_gem(installer.gem,
                              Gem::OpenPGP.options[:get_key])
    end
  rescue Gem::OpenPGPException => ex
    installer.alert_error(ex.message)
    installer.terminate_interaction(1)
  end
end
