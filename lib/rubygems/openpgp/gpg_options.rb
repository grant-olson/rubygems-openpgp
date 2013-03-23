require 'shellwords'


module Gem::OpenPGP
  extend Shellwords

  WHITELISTED_GPG_OPTIONS = {
    "homedir" => "dir",
    "verbose" => nil,
    "default-key" => "user_id",
    "local-user" => "user_id",
    "passphrase-fd" => "file_descriptor",
    "passphrase-file" => "file_name"
  }

  def self.gpg_options
    @gpg_options ||= {}
    @gpg_options
  end
  
  def self.add_gpg_options cmd
    WHITELISTED_GPG_OPTIONS.each_pair do |flag, arg|
      mangled_flag = "--gpg-#{flag}"
      mangled_flag += " #{arg}" if arg.is_a? String

      cmd.add_option(mangled_flag,"Forward option --#{flag} to gpg") do |value, options|
        value = true if arg.nil? #boolean
        gpg_options[flag] = value
      end
    end
  end

  def self.get_gpg_options
    options = []
    gpg_options.each_pair do |flag, value|
      new_flag = "--#{flag}"
      if value.is_a? String
        new_flag += " " + shellescape(value)
      end
      options << new_flag
    end

    options.join(" ")
  end
  
end
