require 'test/unit'
require 'rubygems_plugin'
require 'rubygems/gem_openpgp'
require 'tmpdir'

class RubygemsPluginTest < Test::Unit::TestCase
  def test_basic_sign_and_verify
    gpg_home = Dir.mktmpdir()
    `gpg --homedir=#{gpg_home} --import test/pablo_escobar_seckey.asc`
    `gpg --homedir=#{gpg_home} --import test/pablo_escobar_pubkey.asc`

    data = "The mysterious case of Pablo Escobar's hippos - http://baraza.wildlifedirect.org/2009/07/15/the-curious-case-of-pablo-escobars-hippos/"

    sig = Gem::OpenPGP.detach_sign data, key_id=nil, homedir=gpg_home
    assert_nothing_raised do
      Gem::OpenPGP.verify data, sig, false, homedir=gpg_home
    end

    # BAD SIG
    assert_raise(Gem::OpenPGPException) do
      Gem::OpenPGP.verify data + "\n", sig, false, homedir=gpg_home
    end

  end
end
