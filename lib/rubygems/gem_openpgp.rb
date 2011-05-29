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
  def self.detach_sign data, key_id=nil
    is_gpg_available
    is_key_valid key_id if key_id
    
    key_flag = ""
    key_flag = "-u #{key_id}" if key_id
    cmd = "gpg #{key_flag} --detach-sign --armor"
    exit_status = nil
    sig,err = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.write data
      stdin.close
      exit_status = wait_thr.value
      [stdout.read(), stderr.read()]
    end

    raise "gpg error #{err}" if exit_status != 0

    sig
  end

  # Given a string containing data, and a string containing
  # a detached signature, verify the data.  If we can't verify
  # then raise an exception.
  #
  # Optionally tell gpg to retrive the key if it's not provided
  def self.verify data, sig, get_key=false
    is_gpg_available
    
    data_file = Tempfile.new("rubygems_data")
    data_file.binmode
    data_file.write(data)
    data_file.close

    sig_file = Tempfile.new("rubygems_sig")
    sig_file.binmode
    sig_file.write(sig)
    sig_file.close

    get_key_params = "--keyserver pool.sks-keyservers.net --keyserver-options auto-key-retrieve"
    get_key_params = "" if get_key != true

    cmd = "gpg #{get_key_params} --verify #{sig_file.path} #{data_file.path}"
    exit_status = nil
    res, err = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      exit_status = wait_thr.value
      [ stdout.read(), stderr.read() ]
    end

    color_code = if exit_status == 0
                   "32"
                 else
                   "31"
                 end
    
    puts "\033[#{color_code}m#{err}\033[0m"
    puts "\033[37m #{res} \033[0m"

    raise "gpg encountered errors! #{err}" if exit_status != 0
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
end
