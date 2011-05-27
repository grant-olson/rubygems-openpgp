require "rubygems/command"
require 'rubygems/version_option'

class Gem::Commands::SbuildCommand < Gem::Command

  include Gem::VersionOption

  def initialize
    super 'sbuild', 'Build your gem, then sign it with OpenPGP'

    add_version_option

  end

  def arguments
    "GEMNAME        name of gem to build"
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
