require "rubygems/command"
require "rubygems/package"
require 'rubygems/version_option'
require "rubygems/gem_openpgp"
require 'fileutils'

# Signs an existing gemfile by iterating the tar'ed up contents,
# and signing any contents. creating a new file with original contents
# and OpenPGP sigs.  The OpenPGP sigs are saved as .asc files so they 
# won't conflict with X509 sigs.
#
# Optional param "--key KEY" allows you to use a different private
# key than the GPG default.
class Gem::Commands::SignCommand < Gem::Command

  include Gem::VersionOption

  def initialize # :nodoc:
    super 'sign', 'Sign existing gem with your OpenPGP key', :key => nil

    add_version_option

    add_option('--key KEY', "Specify key id if you don't want to use your default gpg key") do |key, options|
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
    "blah blah"
  end

  def execute  # :nodoc:
    version = options[:version] || Gem::Requirement.default
    gem, specs = get_one_gem_name, []

    unsigned_gem = gem + ".unsigned"
    FileUtils.mv gem, unsigned_gem
    
    unsigned_gem_file = File.open(unsigned_gem, "r")
    signed_gem_file = File.open(gem, "w")

    signed_gem = Gem::Package::TarWriter.new(signed_gem_file)

    Gem::Package::TarReader.new(unsigned_gem_file).each do |f|
      say f.full_name.inspect
      
      if f.full_name[-4..-1] == ".asc"
        say "Skipping old signature file #{f.full_name}"
        next
      end
      
      say "Signing #{f.full_name.inspect}..."

      file_contents = f.read()

      signed_gem.add_file(f.full_name, 0644) do |outfile|
        outfile.write(file_contents)
      end

      signed_gem.add_file(f.full_name + ".asc", 0644) do |outfile|
        outfile.write(Gem::OpenPGP.detach_sign(file_contents,options[:key]))
      end

    end
  rescue Exception => ex
    FileUtils.mv unsigned_gem_file, gem
    raise
  end

end
