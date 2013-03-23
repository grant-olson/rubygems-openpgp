require 'test/unit'
require 'mocha/setup'

require "rubygems/command"
require 'rubygems/openpgp/gpg_options'

class Gem::Commands::TestCommand < Gem::Command
end

class GpgOptionsText < Test::Unit::TestCase
  def setup
    @test_cmd = Gem::Command.new "test", "summary"
    Gem::OpenPGP.add_gpg_options(@test_cmd)
  end

  def teardown
    Gem::OpenPGP.instance_variable_set(:@gpg_options,{})
  end

  def test_option_with_argument
    @test_cmd.handle_options %W[--gpg-homedir /home/foo/alt-dir]
    assert_equal Gem::OpenPGP.gpg_options["homedir"], "/home/foo/alt-dir"
  end
  
  def test_option_with_argument_build
    @test_cmd.handle_options %W[--gpg-homedir /home/foo/alt-dir]
    assert_equal Gem::OpenPGP.get_gpg_options, "--homedir /home/foo/alt-dir"
  end
  
  def test_option
    @test_cmd.handle_options %W[--gpg-verbose]
    assert_equal Gem::OpenPGP.gpg_options["verbose"], true
  end
  
  def test_option_build
    @test_cmd.handle_options %W[--gpg-verbose]
    assert_equal Gem::OpenPGP.get_gpg_options, "--verbose"
  end
  
  
end
