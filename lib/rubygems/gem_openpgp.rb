require 'rubygems'
require 'rubygems/package'
require 'rubygems/user_interaction'
require 'shellwords'
require 'open3'
require 'tempfile'
require 'gpg_status_parser'
require 'rubygems/openpgp/keymaster'

# Exception for this class
class Gem::OpenPGPException < RuntimeError; end

# A wrapper that shells out the real OpenPGP crypto work
# to gpg.
module Gem::OpenPGP
  extend Shellwords
  extend Gem::UserInteraction

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
    gpg_results = run_gpg(gpg_args, data)
    did_gpg_error? gpg_results

    gpg_results[:stdout]
  end

  # Extract the info we care about, throw away the rest  
  def self.verify_extract_status_info message, status_info
      case message.status
      when :GOODSIG, :BADSIG, :ERRSIG
        status_info[:good_or_bad] = message.status
        status_info[:uid] = (message.args[:username] || "").strip
        
      when :SIG_ID
      when :VALIDSIG, :EXPSIG, :BADSIG
        status_info[:sig_status] = message.status
        status_info[:primary_key] = "0x#{message.args[:primary_key_fpr][-9..-1]}"
        status_info[:primary_key_fingerprint] = message.args[:primary_key_fpr]
      when :TRUST_UNDEFINED, :TRUST_NEVER, :TRUST_MARGINAL, :TRUST_FULLY, :TRUST_ULTIMATE
        status_info[:trust_status] = message.status
      when :NO_PUBKEY
        status_info[:failure] = "You don't have the public key.  Use --get-key to automagically retrieve from keyservers"
      when :IMPORTED, :IMPORT_OK, :IMPORT_RES
        #silently_ignore
      when :KEYEXPIRED, :SIGEXPIRED
        # recalculating trust db, ignore.
      else
        puts "unexpected message: #{message.status} #{message.args.inspect}"
      end
  end

  # Print info about the sig, check that we like it, and possibly abort
  def self.verify_check_sig status_info
    sig_msg = "Signature for #{status_info[:file_name]} from user #{status_info[:uid]} key #{status_info[:primary_key]} is #{status_info[:good_or_bad]}, #{status_info[:sig_status]} and #{status_info[:trust_status]}"
    if status_info[:trust_status] == :TRUST_NEVER
      say add_color(sig_msg, :red)
      raise Gem::OpenPGPException, "Never Trusted.  Won't install."
    elsif status_info[:trust_status] == :TRUST_UNDEFINED
      say add_color(sig_msg, :yellow)
      if options[:trust] && !options[:no_trust]
        raise Gem::OpenPGPException, "Trust Undefined and you've specified --trust.  Won't install."
      end
    else
      say add_color(sig_msg , :green)
    end
  end

  # Given a string containing data, and a string containing
  # a detached signature, verify the data.  If we can't verify
  # then raise an exception.
  #
  # Optionally tell gpg to retrive the key if it's not provided
  #
  # returns the fingerprint used to sign the file
  def self.verify file_name, data, sig, get_key=false, homedir=nil
    is_gpg_available
    is_homedir_valid homedir if homedir

    data_file = create_tempfile data
    sig_file = create_tempfile sig

    get_key_params = "--keyserver pool.sks-keyservers.net --keyserver-options auto-key-retrieve"
    get_key_params = "" if get_key != true

    homedir_flags = ""
    homedir_flags = "--homedir #{homedir}" if homedir

    gpg_args = "#{get_key_params} #{homedir_flags} --verify #{sig_file.path} #{data_file.path}"
    
    status_info = {:file_name => file_name}
    gpg_results = run_gpg(gpg_args) { |message| verify_extract_status_info(message, status_info) }
    
    if status_info[:failure]
      say add_color(status_info[:failure], :red)
      raise Gem::OpenPGPException, "Fail!"
    else
      verify_check_sig status_info
    end

    did_gpg_error? gpg_results

    status_info[:primary_key_fingerprint]
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
      say(f.full_name.inspect)
      
      if f.full_name[-4..-1] == ".asc"
        say("Skipping old signature file #{f.full_name}")
        next
      end
      
      say("Signing #{f.full_name.inspect}...")

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

  rescue Exception => ex
    if unsigned_gem_file
      FileUtils.mv unsigned_gem_file, gem
    end
    
    raise
  end

  def self.verify_gem_check_fingerprint gem_name, fingerprint
    if !Gem::OpenPGP::KeyMaster.check_fingerprint(gem_name, fingerprint)
      raise Gem::OpenPGPException, "Gem #{gem_name} fingerprint #{fingerprint} didn't match fingerprint in ~/.rubygems-openpgp/known_gems.  Won't install!"
    end
  end



  def self.verify_gem gem, get_key=false, homedir=nil
    raise Gem::CommandLineError, "Gem #{gem} not found."  if !File.exists?(gem)

    gem_name = Gem::Format.from_file_by_path(gem).spec.name # rubygems 2.0.0 safe?
    say("Verifying #{gem_name}...")

    file = File.open(gem,"r")

    fingerprints = []
    tar_files = {}

    Gem::Package::TarReader.new(file).each do |f|
      tar_files[f.full_name] = f.read()
    end
    
    tar_files.keys.each do |file_name|
      next if file_name[-4..-1] == ".asc"

      sig_file_name = file_name + ".asc"
      if !tar_files.has_key? sig_file_name
        say add_color("WARNING!!! No sig found for #{file_name}", :red)
        raise Gem::OpenPGPException, "Can't verify without sig, aborting!!!"
      end
      
      begin
        fingerprints << Gem::OpenPGP.verify(file_name, tar_files[file_name], tar_files[sig_file_name], get_key, homedir)
      rescue Gem::OpenPGPException => ex
        color_code = "31"
        say add_color(ex.message, :red)
        raise
      end
    end

    # Verify fingerprint
    fingerprints.uniq.each do |fp|
      verify_gem_check_fingerprint gem_name, fp
    end
    
  ensure
    file.close unless file.nil?
  end

private

  def self.did_gpg_error? gpg_results
    if gpg_results[:status] != 0
      say add_color("gpg returned unexpected status code", :red)
      say add_color(gpg_results[:stdout], :yellow)
      say add_color(gpg_results[:stderr], :red)
      raise Gem::OpenPGPException, "gpg returned unexpected error code #{gpg_results[:status]}"
    end
  end

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
  
  def self.run_gpg args, data=nil, &block
    exit_status = nil
    status_file = Tempfile.new("status")

    full_gpg_command = "gpg --status-file #{status_file.path} #{args}"
    gpg_results = Open3.popen3(full_gpg_command) do |stdin, stdout, stderr, wait_thr|
      stdin.write data if data
      stdin.close
      exit_status = wait_thr.value
      GPGStatusParser.parse(status_file, &block)
      out = stdout.read()
      err = stderr.read()
      {:status => exit_status, :stdout => out, :err => err}
    end
    gpg_results
  ensure
    status_file.close
    status_file.unlink
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
                 when :yellow then "33"
                 else raise RuntimeError, "Invalid color #{color.inspect}"
                 end
    
    #TODO - NO-OP on windows
    "\033[#{color_code}m#{s}\033[0m"
  end

  def self.options
    @options ||= {}
    @options
  end
end
