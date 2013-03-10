Gem::Specification.new do |s|
  s.name        = 'rubygems-openpgp'
  s.version     = '0.6.0.pre'
  s.date        = '2013-03-10'
  s.summary     = "Sign gems via OpenPGP"
  s.description = "Digitally sign gems via OpenPGP."
  s.authors     = ["Grant Olson"]
  s.email       = 'kgo@grant-olson.net'
  s.files       = ["LICENSE",
  		   "Rakefile",
                   "lib/rubygems_plugin.rb",
  		   "lib/rubygems/commands/verify_command.rb",
                   "lib/rubygems/commands/sign_command.rb",
		   "lib/rubygems/gem_openpgp.rb",
                   "lib/rubygems/openpgp/gpg_helpers.rb",
                   "lib/rubygems/openpgp/options.rb",
                   "lib/rubygems/openpgp/signing.rb",
                   "lib/rubygems/openpgp/verification.rb",
                   "lib/rubygems/openpgp/keymaster.rb",
                   "lib/rubygems/openpgp/verify_plugins.rb",
                   "lib/rubygems/openpgp/sign_plugins.rb",
                   "lib/rubygems/openpgp/openpgpexception.rb"]
  s.test_files  = ["test/test_keymaster.rb",
                   "test/test_rubygems-openpgp.rb",
                   "test/pablo_escobar_seckey.asc",
		   "test/pablo_escobar_pubkey.asc",
		   "test/unsigned_hola-0.0.0.gem"]
  s.homepage    = 'https://rubygems-openpgp-ca.org'
  s.license     = "BSD 3 Clause"
  s.extra_rdoc_files = ['README.md']

  s.add_dependency("gpg_status_parser",">= 0.4.0")
  s.add_development_dependency("mocha", ">= 0.13.2")
end