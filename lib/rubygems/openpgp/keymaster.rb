module Gem::OpenPGP
  # Capture used signing keys so we can see if they changed.
  module KeyMaster
    SETTING_DIR = ".rubygems-openpgp"
    KEYMASTER_FILE = "known_gems"

    def self.full_setting_filename
      home_dir = ENV["HOME"] || ENV["HOMEPATH"]
      File.join(home_dir, SETTING_DIR, KEYMASTER_FILE)
    end
    
    def self.touch_keymaster_file
      home_dir = ENV["HOME"] || ENV["HOMEPATH"]
      
      setting_dir = File.join(home_dir, SETTING_DIR)
      Dir.mkdir(setting_dir, 0700) if !File.directory? setting_dir

      if !File.exists?(full_setting_filename)
        File.open(full_setting_filename,"w").close
      end
    end
    
    def self.load_fingerprints
      touch_keymaster_file

      home_dir = ENV["HOME"] || ENV["HOMEPATH"]

      fingerprints = {}
      File.open(full_setting_filename) do |f|
        f.readlines.each do |line|
          gem, fingerprint = line.strip.split("\t")
          fingerprints[gem] = fingerprint
        end
      end

      fingerprints
    end
    
    def self.save_fingerprints fingerprints
      touch_keymaster_file

      File.open(full_setting_filename,"w") do |f|
        fingerprints.each_pair do |gem, fingerprint|
          f.puts("#{gem}\t#{fingerprint}")
        end
      end
    end

    def self.get_fingerprint gem_name
      load_fingerprints[gem_name]
    end
    
    def self.add_fingerprint gem_name, fingerprint
      fingerprints = load_fingerprints
      fingerprints[gem_name] = fingerprint
      save_fingerprints fingerprints
    end

    # Check that an existing gem fingerprint matches a given fingerprint.
    # In the case we haven't seen the gem before, we'll add the fingerprint
    # and won't complain.
    def self.check_fingerprint gem_name, fingerprint
      fingerprints = load_fingerprints
      
      if !fingerprints.has_key?(gem_name)
        add_fingerprint gem_name, fingerprint
        return true
      end

      fingerprints[gem_name] == fingerprint
    end
    
  end
end
