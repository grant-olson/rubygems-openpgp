Gem::Specification.new do |s|
  s.name        = 'rubygems-openpgp'
  s.version     = '0.0.0'
  s.date        = '2010-05-27'
  s.summary     = "Sign gems via OpenPGP"
  s.description = "Digitally sign gems via OpenPGP instead of OpenSSL"
  s.authors     = ["Grant Olson"]
  s.email       = 'kgo@grant-olson.net'
  s.files       = ["lib/rubygems_plugin.rb",
  		   "lib/rubygems/commands/verify_command.rb",
		   "lib/rubygems/commands/vinstall_command.rb",
		   "lib/rubygems/commands/sbuild_command.rb",
                   "lib/rubygems/commands/sign_command.rb"]
  s.homepage    =
    'http://rubygems.org/gems/hola'
end