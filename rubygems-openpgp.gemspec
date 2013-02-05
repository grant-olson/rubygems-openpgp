require File.expand_path('../lib/rubygems/gem_openpgp/version', __FILE__)

Gem::Specification.new do |s|
  s.name             = 'rubygems-openpgp'
  s.version          = Gem::OpenPGP::VERSION
  s.date             = '2010-05-30'
  s.summary          = "Sign gems via OpenPGP"
  s.description      = "Digitally sign gems via OpenPGP instead of OpenSSL"
  s.authors          = ["Grant Olson"]
  s.email            = 'kgo@grant-olson.net'
  s.files            = Dir.glob('lib/**/*') + ['LICENSE', 'Rakefile']
  s.test_files       = Dir.glob('test/**/*')
  s.homepage         = 'https://github.com/grant-olson/rubygems-openpgp'
  s.license          = "BSD 3 Clause"
  s.extra_rdoc_files = ['README.md']
end
