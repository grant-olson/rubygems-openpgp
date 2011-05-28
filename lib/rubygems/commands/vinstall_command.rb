require "rubygems/command"
require 'rubygems/version_option'

class Gem::Commands::VinstallCommand < Gem::Command

  include Gem::VersionOption

  def initialize
    super 'vinstall', 'verify gem with GPG, and only install if sig check passes'

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

    puts "Not implemented yet."
  end

end
