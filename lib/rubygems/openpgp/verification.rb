require 'rubygems'
require 'rubygems/package'
require 'rubygems/user_interaction'

require 'tempfile'
require 'rbconfig'

require 'gpg_status_parser'

require 'rubygems/openpgp/keymaster'
require 'rubygems/openpgp/options'
require 'rubygems/openpgp/gpg_helpers'
require 'rubygems/openpgp/openpgpexception'
require 'rubygems/openpgp/owner_check'

module Gem::OpenPGP
  extend Gem::UserInteraction

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

    gpg_args = "#{get_key_params} #{homedir_flags} #{Gem::OpenPGP.get_gpg_options} --with-colons --verify #{sig_file.path} #{data_file.path}"
    
    status_info = {:file_name => file_name}
    gpg_results = GPGStatusParser.run_gpg(gpg_args) { |message| verify_extract_status_info(message, status_info) }
    
    if status_info[:failure]
      say add_color(status_info[:failure], :red)
      raise Gem::OpenPGPException, "Fail!"
    else
      verify_check_sig status_info
    end

    did_gpg_error? gpg_results

    status_info[:primary_key_fingerprint]
  end

  def self.verify_gem gem, get_key=false, homedir=nil
    raise Gem::CommandLineError, "Gem #{gem} not found."  if !File.exists?(gem)

    gem_name = if Gem::VERSION[0..1] == "2." #gotta be a better way
                 Gem::Package.new(gem).spec.name
               else
                 Gem::Format.from_file_by_path(gem).spec.name
               end
    
    say("Verifying #{gem_name}...")

    file = File.open(gem,"r")

    fingerprints = []
    tar_files = {}

    Gem::Package::TarReader.new(file).each do |f|
      tar_files[f.full_name] = f.read()
    end
    
    tar_files.keys.each do |file_name|
      next if [".asc",".sig"].include? file_name[-4..-1]

      if file_name[-3..-1] != ".gz"
        say add_color("Skipping #{file_name}.  Only expected .gz files...", :yellow)
        next
      end

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

    fingerprints.uniq!
    
    # Verify fingerprint and owner
    fingerprints.each do |fp|
      verify_gem_check_fingerprint gem_name, fp
      owner_checks gem_name, fp
    end
    
  ensure
    file.close unless file.nil?
  end

  private

  def self.owner_checks gem_name, fp
    if !check_rubygems_org_owner(gem_name, fp)
      if options[:ignore_owner_check]
        say add_color("Ignoring bad owner status because you told me to!",:yellow)
      else
        say add_color("Use --ignore-owner-check to install anyway.", :yellow)
        raise Gem::OpenPGPException, "BADOWNER"
      end
    end
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
        status_info[:primary_key] = "0x#{message.args[:primary_key_fpr][-8..-1]}"
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

  def self.verify_gem_check_fingerprint gem_name, fingerprint
    if !Gem::OpenPGP::KeyMaster.check_fingerprint(gem_name, fingerprint)
      raise Gem::OpenPGPException, "Gem #{gem_name} fingerprint #{fingerprint} didn't match fingerprint in #{Gem::OpenPGP::KeyMaster.full_setting_filename}.  Won't install!"
    end
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
    
    if (RbConfig::CONFIG['host_os'] =~ /mswin|mingw/) 
      s # no colors on windows
    else
      "\033[#{color_code}m#{s}\033[0m"
    end
    
  end

end
