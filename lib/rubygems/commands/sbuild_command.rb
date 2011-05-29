require "rubygems/command"
require 'rubygems/version_option'

# currently unimplemented.
# This will build and sign with a single command.
class Gem::Commands::SbuildCommand < Gem::Command # :nodoc:

  include Gem::VersionOption

  def initialize # :nodoc:
    super 'sbuild', 'Build your gem, then sign it with OpenPGP'

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

    raise "Not implemented yet"
  end

end
