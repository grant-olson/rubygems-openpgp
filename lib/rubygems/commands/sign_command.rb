require "rubygems/command"
require 'rubygems/version_option'

class Gem::Commands::SignCommand < Gem::Command

  include Gem::VersionOption

  def initialize
    super 'sign', 'Sign existing gem with your OpenPGP key', :key => nil

    add_version_option

    add_option('--key', "Specify key id if you don't want to use your default gpg key") do |key, options|
      puts all.inspect, options.inspect
    end
  end

  def arguments
    "GEMNAME        name of gem to sign"
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
