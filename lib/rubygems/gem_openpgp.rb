require 'open3'
require 'tempfile'

# A wrapper that shells out the real OpenPGP crypto work
# to gpg.
module Gem::OpenPGP

  # Tests to see if gpg is installed and available.
  def self.openpgp_available?
    `gpg --version`
    $? == 0
  rescue
    false
  end

  # Given a string of data, generate and return a detached
  # signature.  By defualt, this will use your primary secret key.
  # This can be overridden by specifying a key_id for another 
  # private key.
  def self.detach_sign data, key_id=nil
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
end
