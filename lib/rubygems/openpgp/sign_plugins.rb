require 'rubygems/command_manager'
require 'rubygems/gem_openpgp'

Gem::CommandManager.instance.register_command :sign

# gem build hooks
b = Gem::CommandManager.instance[:build]
b.add_option("--sign", "Sign gem with OpenPGP.") do |value, options|
  Gem::OpenPGP.options[:sign] = true
end

b.add_option('--key KEY', "Specify key id if you don't want to use your default gpg key") do |key, options|
  Gem::OpenPGP.options[:key] = key
end

class Gem::Commands::BuildCommand
  alias_method :original_execute, :execute
  def execute
    original_execute

    if Gem::OpenPGP.options[:sign]
      gemspec = get_one_gem_name
      if File.exist? gemspec then
        spec = Gem::Specification.load gemspec
        file_name = File.join(".", File.basename(spec.cache_file))
        Gem::OpenPGP.sign_gem file_name, key=Gem::OpenPGP.options[:key]
      end
    end
  end
end

