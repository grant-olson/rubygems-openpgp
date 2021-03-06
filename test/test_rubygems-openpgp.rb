require 'test/unit'
require 'mocha/setup'

require 'rubygems_plugin'
require 'rubygems/gem_openpgp'
require 'tmpdir'
require 'fileutils'

class RubygemsPluginTest < Test::Unit::TestCase
  UNSIGNED_GEM = "test/unsigned_hola-0.0.0.gem"
  SIGNED_GEM = "test/openpgp_signed_hola-0.0.0.gem"
  PABLOS_SECKEY = "test/pablo_escobar_seckey.asc"
  PABLOS_PUBKEY = "test/pablo_escobar_pubkey.asc"

  def in_tmp_gpg_homedir
    gpg_home = Dir.mktmpdir()
    `gpg --homedir=#{gpg_home} --import #{PABLOS_SECKEY}`
    `gpg --homedir=#{gpg_home} --import #{PABLOS_PUBKEY}`

    Gem::OpenPGP.stubs(:get_gpg_options => "--homedir #{gpg_home}")
    yield gpg_home
    FileUtils.rm_rf(gpg_home)
  end
  
  def test_gem_sign_and_verify
    Gem::OpenPGP.stubs(:verify_gem_check_fingerprint => true, :check_rubygems_org_owner => true)

    in_tmp_gpg_homedir do
      assert_raise Gem::OpenPGPException do
        Gem::OpenPGP.verify_gem UNSIGNED_GEM
      end

      FileUtils.cp UNSIGNED_GEM, SIGNED_GEM
    
      assert_nothing_raised do
        Gem::OpenPGP.sign_gem SIGNED_GEM
        Gem::OpenPGP.verify_gem SIGNED_GEM
      end
    end
  ensure
    File.delete(SIGNED_GEM) if File.exists?(SIGNED_GEM)
  end
  
  def test_basic_sign_and_verify
    in_tmp_gpg_homedir do
      data = "The mysterious case of Pablo Escobar's hippos - http://baraza.wildlifedirect.org/2009/07/15/the-curious-case-of-pablo-escobars-hippos/"

      sig = Gem::OpenPGP.detach_sign data
      assert_nothing_raised do
        Gem::OpenPGP.verify "<file>", data, sig
      end

      # BAD SIG
      assert_raise(Gem::OpenPGPException) do
        Gem::OpenPGP.verify "<file>", data + "\n", sig
      end
    end
  end
end
