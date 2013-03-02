require 'test/unit'
require 'mocha/setup'

require 'rubygems/openpgp/keymaster'

class KeymasterTest < Test::Unit::TestCase
  def setup
    Gem::OpenPGP::KeyMaster.stubs(:load_fingerprints => {"foo" => "DEADBEEF"},
                                  :save_fingerprints => nil)
  end
  
  
  def test_good_fingerprint
    assert_block("Good fingerprint test") do
      Gem::OpenPGP::KeyMaster.check_fingerprint("foo", "DEADBEEF") == true
    end
  end
  
  def test_bad_fingerprint
    assert_block("Bad fingerprint test") do
      Gem::OpenPGP::KeyMaster.check_fingerprint("foo", "C00FFEE") != true
    end
  end
  
  def test_new_gem
    assert_block("New gem test") do
      Gem::OpenPGP::KeyMaster.check_fingerprint("bar", "C00FFEE") == true
    end
  end
  
end
