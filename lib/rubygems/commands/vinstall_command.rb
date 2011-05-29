require "rubygems/command"
require 'rubygems/version_option'

# Currently unimplemented.
# This will fetch, verify and install a gem.  Ideally it will do the
# same with any dependencies that are downloaded, but this might be 
# difficult in a gem.
class Gem::Commands::VinstallCommand < Gem::Command # :nodoc:

  include Gem::VersionOption

  def initialize # :nodoc:
    super 'vinstall', 'verify gem with GPG, and only install if sig check passes'

    add_version_option

  end

  def arguments # :nodoc:
    "GEMNAME        name of gem to build"
  end
  
  def defaults_str # :nodoc:
    ""
  end

  def usage # :nodoc:
    "blah blah"
  end

  def execute # :nodoc:
    version = options[:version] || Gem::Requirement.default

    puts "Not implemented yet."
  end

end
