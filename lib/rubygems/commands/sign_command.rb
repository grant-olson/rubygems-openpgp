require "rubygems/command"
require "rubygems/package"
require 'rubygems/version_option'
require "rubygems/gem_openpgp"
require 'fileutils'

# CLI interface to the internal signing code:
#
#   gem sign gemname-0.0.0.gem
#
#   gem sign -key 0xDEADBEEF gemname-0.0.0.gem
class Gem::Commands::SignCommand < Gem::Command

  include Gem::VersionOption

  def initialize # :nodoc:
    super 'sign', 'Signs an existing gem with your OpenPGP key.  This allows third parties to verify the key later via the \'gem verify\' command.', :key => nil

    add_version_option

    add_option('--key KEY', "Specify key id if you don't want to use your default gpg key") do |key, options|
      warn("--key deprecated.  Use --gpg-local-user instead")
      options[:key] = key
    end
  end

  def arguments # :nodoc:
    "GEMNAME        name of gem to sign"
  end
  
  def defaults_str # :nodoc:
    ""
  end

  def usage # :nodoc:
    "gem sign GEMNAME"
  end

  def execute  # :nodoc:
    version = options[:version] || Gem::Requirement.default
    gem, specs = get_one_gem_name, []
    Gem::OpenPGP.sign_gem gem, key=options[:key]
  end
  
end
