module Gem::OpenPGP
  extend Gem::UserInteraction

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

end
