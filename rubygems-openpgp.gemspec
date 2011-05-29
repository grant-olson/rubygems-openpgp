Gem::Specification.new do |s|
  s.name        = 'rubygems-openpgp'
  s.version     = '0.2.0'
  s.date        = '2010-05-28'
  s.summary     = "Sign gems via OpenPGP"
  s.description = "Digitally sign gems via OpenPGP instead of OpenSSL"
  s.authors     = ["Grant Olson"]
  s.email       = 'kgo@grant-olson.net'
  s.files       = ["LICENSE",
  		   "Rakefile",
                   "lib/rubygems_plugin.rb",
  		   "lib/rubygems/commands/verify_command.rb",
		   "lib/rubygems/commands/vinstall_command.rb",
		   "lib/rubygems/commands/sbuild_command.rb",
                   "lib/rubygems/commands/sign_command.rb",
		   "lib/rubygems/gem_openpgp.rb"]
  s.test_files  = ["test/test_rubygems-openpgp.rb",
                   "test/pablo_escobar_seckey.asc",
		   "test/pablo_escobar_pubkey.asc",
		   "test/unsigned_hola-0.0.0.gem"]
  s.homepage    = 'https://github.com/grant-olson/rubygems-openpgp'
  s.license     = "BSD 3 Clause"
  s.extra_rdoc_files = ['README.md']
end