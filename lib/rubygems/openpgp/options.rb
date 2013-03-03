module Gem::OpenPGP
  private

  # Store options we get from command line here so sign/verify code
  # can get to it.
  def self.options
    @options ||= {}
    @options
  end
end
