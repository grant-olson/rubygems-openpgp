require 'rubygems'
require 'rubygems/package'
require 'rubygems/user_interaction'
require 'gpg_status_parser'
require 'rubygems/openpgp/gpg_helpers'
require 'rubygems/openpgp/openpgpexception'
require 'shellwords'

module Gem::OpenPGP
  extend Shellwords
  
  # Given a string of data, generate and return a detached
  # signature.  By defualt, this will use your primary secret key.
  # This can be overridden by specifying a key_id for another 
  # private key.
  def self.detach_sign data, key_id=nil, homedir=nil
    is_gpg_available
    is_key_valid key_id if key_id
    is_homedir_valid homedir if homedir

    key_flag = ""
    key_flag = "-u #{shellescape(key_id)}" if key_id

    homedir_flag = ""
    homedir_flag = "--homedir #{shellescape(homedir)}" if homedir

    gpg_args = "#{key_flag} #{homedir_flag} --detach-sign --armor"
    gpg_results = GPGStatusParser.run_gpg(gpg_args, data)
    did_gpg_error? gpg_results

    gpg_results[:stdout]
  end

  # Signs an existing gemfile by iterating the tar'ed up contents,
  # and signing any contents. creating a new file with original contents
  # and OpenPGP sigs.  The OpenPGP sigs are saved as .asc files so they 
  # won't conflict with X509 sigs.
  #
  # Optional param "key" allows you to use a different private
  # key than the GPG default.
  def self.sign_gem gem, key=nil, homedir=nil
    unsigned_gem = gem + ".unsigned"

    begin
      FileUtils.mv gem, unsigned_gem
    rescue Errno::ENOENT => ex
      raise Gem::CommandLineError, "The gem #{gem} does not seem to exist. (#{ex.message})"
    end

    unsigned_gem_file = File.open(unsigned_gem, "r")
    signed_gem_file = File.open(gem, "w")

    signed_gem = Gem::Package::TarWriter.new(signed_gem_file)

    Gem::Package::TarReader.new(unsigned_gem_file).each do |f|

      if f.full_name[-4..-1] == ".asc"
        say("Skipping old OpenPGP signature file #{f.full_name}")
        next
      end

      file_contents = f.read()

      # Copy file no matter what
      signed_gem.add_file(f.full_name, 0644) do |outfile|
        outfile.write(file_contents)
      end

      # Only sign if it's really part of the gem and not
      # a X.509 sig
      if f.full_name[-3..-1] == ".gz"
        say add_color("Signing #{f.full_name.inspect}...",:green)
        signed_gem.add_file(f.full_name + ".asc", 0644) do |outfile|
          outfile.write(Gem::OpenPGP.detach_sign(file_contents,key,homedir))
        end
      elsif f.full_name[-4..-1] != ".sig"
        say add_color("Not signing #{f.full_name.inspect}.  Didn't expect to see that...",:yellow)
      end
    end
    
    signed_gem_file.close
    unsigned_gem_file.close
    File.delete unsigned_gem_file

  rescue Exception => ex
    if unsigned_gem_file
      FileUtils.mv unsigned_gem_file, gem
    end
    
    raise
  end

  private

  def self.is_key_valid key_id
    valid = /^0x[A-Za-z0-9]{8,8}/.match(key_id)
    if valid.nil?
      err_msg = "Invalid key id.  Keys should be in form of 0xDEADBEEF"
      raise Gem::OpenPGPException, err_msg
    end
  end
 
  def self.is_homedir_valid homedir
    if !File.exists? homedir
      raise OpenPGPException, "Bad homedir #{homedir.inspect}"
    end
  end

end
