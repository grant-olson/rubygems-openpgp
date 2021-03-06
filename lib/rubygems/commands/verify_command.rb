require 'rubygems/command'
require 'rubygems/package'
require 'rubygems/user_interaction'
require 'rubygems/version_option'
require 'rubygems/gem_openpgp'

# Verifies a gem signed by the 'sign' command.  Iterates through the
# gem contents and verifies all embedded files, if possible.  Errors
# out if the signature is bad or the key is unknown.
#
# Optionally takes "--get-key" which automatically retreives the key
# from keyservers to make things easier for people unfamiliar with gpg.
class Gem::Commands::VerifyCommand < Gem::Command

  include Gem::VersionOption
  include Gem::UserInteraction

  def initialize # :nodoc:
    super 'verify', 'Verifies a local gem that has been signed via OpenPGP.  This helps to ensure the gem has not been tampered with in transit.'

    add_version_option

    add_option('--get-key', "If the key is not available, download it from a keyserver") do |key, options|
      options[:get_key] = true
    end

    add_option("--trust",
                 'Enforce gnupg trust settings.  Only install if trusted.') do |value, options|
      Gem::OpenPGP.options[:trust] = true
    end

    add_option("--no-trust",
                 "Ignoure gnupg trust settings,  even if --trust has previously been specified") do |value, options|
      Gem::OpenPGP.options[:no_trust] = true
    end

  end

  def arguments # :nodoc:
    "GEMNAME        name of gem to verify"
  end
  
  def defaults_str # :nodoc:
    ""
  end

  def usage # :nodoc:
    "gem verify GEMNAME"
  end

  def execute # :nodoc:
    version = options[:version] || Gem::Requirement.default
    gem, specs = get_one_gem_name, []
    Gem::OpenPGP.verify_gem gem, get_key=options[:get_key]
  rescue Gem::OpenPGPException => ex
    alert_error(ex.message)
    terminate_interaction(1)
  end
  
end
