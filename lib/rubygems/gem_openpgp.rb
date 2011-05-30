require 'rubygems'
require 'rubygems/package'
require 'open3'
require 'tempfile'

# Exception for this class
class Gem::OpenPGPException < RuntimeError; end

# A wrapper that shells out the real OpenPGP crypto work
# to gpg.
module Gem::OpenPGP

  # Given a string of data, generate and return a detached
  # signature.  By defualt, this will use your primary secret key.
  # This can be overridden by specifying a key_id for another 
  # private key.
  def self.detach_sign data, key_id=nil, homedir=nil
    is_gpg_available
    is_key_valid key_id if key_id
    is_homedir_valid homedir if homedir

    key_flag = ""
    key_flag = "-u #{key_id}" if key_id

    homedir_flag = ""
    homedir_flag = "--homedir #{homedir}" if homedir

    cmd = "gpg #{key_flag} #{homedir_flag} --detach-sign --armor"
    sig, err = run_gpg_command cmd, data
    sig
  end

  # Given a string containing data, and a string containing
  # a detached signature, verify the data.  If we can't verify
  # then raise an exception.
  #
  # Optionally tell gpg to retrive the key if it's not provided
  def self.verify data, sig, get_key=false, homedir=nil
    is_gpg_available
    is_homedir_valid homedir if homedir

    data_file = create_tempfile data
    sig_file = create_tempfile sig

    get_key_params = "--keyserver pool.sks-keyservers.net --keyserver-options auto-key-retrieve"
    get_key_params = "" if get_key != true

    homedir_flags = ""
    homedir_flags = "--homedir #{homedir}" if homedir
 
    cmd = "gpg #{get_key_params} #{homedir_flags} --verify #{sig_file.path} #{data_file.path}"
    res, err = run_gpg_command cmd
    [err, res]
  end

  # Signs an existing gemfile by iterating the tar'ed up contents,
  # and signing any contents. creating a new file with original contents
  # and OpenPGP sigs.  The OpenPGP sigs are saved as .asc files so they 
  # won't conflict with X509 sigs.
  #
  # Optional param "key" allows you to use a different private
  # key than the GPG default.
  def self.sign_gem gem, key=nil, homedir=nil
    output = []

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
      output << f.full_name.inspect
      
      if f.full_name[-4..-1] == ".asc"
        output << "Skipping old signature file #{f.full_name}"
        next
      end
      
      output << "Signing #{f.full_name.inspect}..."

      file_contents = f.read()

      signed_gem.add_file(f.full_name, 0644) do |outfile|
        outfile.write(file_contents)
      end

      signed_gem.add_file(f.full_name + ".asc", 0644) do |outfile|
        outfile.write(Gem::OpenPGP.detach_sign(file_contents,key,homedir))
      end

    end
    
    signed_gem_file.close
    unsigned_gem_file.close
    File.delete unsigned_gem_file

    output
  rescue Exception => ex
    if unsigned_gem_file
      FileUtils.mv unsigned_gem_file, gem
    end
    
    raise
  end

  def self.verify_gem gem, get_key=false, homedir=nil
    output =[]

    begin
      file = File.open(gem,"r")
    rescue Errno::ENOENT => ex
      raise Gem::CommandLineError, "Gem #{gem} not found.  Note you can only verify local gems at this time, so you may need to run 'gem fetch #{gem}' before verifying."  
    end
    
    tar_files = {}

    Gem::Package::TarReader.new(file).each do |f|
      tar_files[f.full_name] = f.read()
    end
    
    tar_files.keys.each do |file_name|
      next if file_name[-4..-1] == ".asc"
      output << "Verifying #{file_name}..."

      sig_file_name = file_name + ".asc"
      if !tar_files.has_key? sig_file_name
        output << "WARNING!!! No sig found for #{file_name}"
        next
      end
      
      begin
        err, res = Gem::OpenPGP.verify(tar_files[file_name], tar_files[sig_file_name], get_key, homedir)

        output << add_color(err, :green)
        output << add_color(res, :green)
      rescue Gem::OpenPGPException => ex
        color_code = "31"
        output << add_color(ex.message, :red)
      end
    end

    file.close
    
    output
  end

private

  # Tests to see if gpg is installed and available.
  def self.is_gpg_available
    err_msg = "Unable to find a working gnupg installation.  Make sure gnupg is installed and you can call 'gpg --version' from a command prompt."
    `gpg --version`
    raise Gem::OpenPGPException, err_msg if $? != 0
  rescue Errno::ENOENT => ex
    raise Gem::OpenPGPException, err_msg if $? != 0
  end

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
  
  def self.run_gpg_command cmd, data=nil
    exit_status = nil
    stdout, stderr = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.write data if data
      stdin.close
      exit_status = wait_thr.value
      out = stdout.read()
      err = stderr.read()
      raise Gem::OpenPGPException, "#{err}" if exit_status != 0
      [out,err]
    end
    [stdout, stderr]
  end

  def self.create_tempfile data
    temp_file = Tempfile.new("rubygems_gpg")
    temp_file.binmode
    temp_file.write(data)
    temp_file.close
    temp_file
  end

  def self.add_color s, color=:green
    color_code = case color
                 when :green then "32"
                 when :red then "31"
                 else raise RuntimeError, "Invalid color #{color.inspect}"
                 end
    
    #TODO - NO-OP on windows
    "\033[#{color_code}m#{s}\033[0m"
  end
  
end
