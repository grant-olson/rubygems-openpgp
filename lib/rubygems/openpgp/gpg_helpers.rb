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
    
    `gpg --version`
    abort_if_shell_error
  rescue Errno::ENOENT => ex
    abort_if_shell_error
  end

  def self.abort_if_shell_error
    install_msg = <<FOO
Couldn't find gpg.  Don't have it? It'll only take a few minutes to install.

Windows installer available at http://gpg4win.org/

OSX installer available at https://www.gpgtools.org/

FOO
    err_msg = "Unable to find a working gnupg installation.  Make sure gnupg is installed and you can call 'gpg --version' from a command prompt."

    if $? != 0
      puts install_msg
      raise Gem::OpenPGPException, err_msg
    end
  end
  

end
