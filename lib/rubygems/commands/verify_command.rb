require "rubygems/command"
require 'rubygems/version_option'

class Gem::Commands::VerifyCommand < Gem::Command

  include Gem::VersionOption

  def initialize
    super 'verify', 'Verify gem with your OpenPGP key'

    add_version_option

  end

  def arguments
    "GEMNAME        name of gem to verify"
  end
  
  def defaults_str
    ""
  end

  def usage
    "blah blah"
  end

  def execute
    version = options[:version] || Gem::Requirement.default

    puts "BOOM"
  end

end
