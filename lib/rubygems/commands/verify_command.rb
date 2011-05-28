require "rubygems/command"
require "rubygems/package"
require 'rubygems/version_option'
require "rubygems/gem_openpgp"

class Gem::Commands::VerifyCommand < Gem::Command

  include Gem::VersionOption

  def initialize
    super 'verify', 'Verify gem with your OpenPGP key'

    add_version_option

    add_option('--get-key', "If the key is not available, download it from a keyserver") do |key, options|
      options[:get_key] = true
    end

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
    gem, specs = get_one_gem_name, []

    file = File.open(gem,"r")

    tar_files = {}

    Gem::Package::TarReader.new(file).each do |f|
      tar_files[f.full_name] = f.read()
    end
    
    tar_files.keys.each do |file_name|
      next if file_name[-4..-1] == ".asc"
      say "Verifying #{file_name}..."

      sig_file_name = file_name + ".asc"
      if !tar_files.has_key? sig_file_name
        say "WARNING!!! No sig found for #{file_name}"
        next
      end
      
      Gem::OpenPGP.verify(tar_files[file_name], tar_files[sig_file_name], options[:get_key])
    end
  end

end
