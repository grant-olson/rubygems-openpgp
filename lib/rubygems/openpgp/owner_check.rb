require 'rubygems/user_interaction'
require 'gems'

module Gem::OpenPGP
  def self.check_rubygems_org_owner gem_name, fingerprint
    uids_and_trust = get_good_uids(fingerprint)
    owners = Gems.owners(gem_name).map { |o| o["email"] }
    
    good_owner_status = find_good_owner(uids_and_trust, owners)
    if !good_owner_status
      valid_uids = uids_and_trust.map { |x| x[:uid] }
      say add_color("Couldn't match good UID against rubygems.org owners!", :red)
      say add_color("\tGood User Ids: #{valid_uids.inspect}", :red)
      say add_color("\trubygems.org owners #{owners.inspect}", :red)
    end
    
    good_owner_status
  rescue Errno::ECONNREFUSED => ex
    say add_color("Can't verify ownership.  Couldn't connect with rubygems.org.", :yellow)
    return false
  end

private

  # Extract good trusted UIDs from a given fingerprint
  def self.get_good_uids fingerprint
    good_uids = []

    key_info = `gpg --with-colons --list-keys #{fingerprint}`
    key_info.split("\n").each do |line|
      line = line.strip
      fields = line.split(":")

      next if !['pub','uid'].include?(fields.first)

      trust = fields[1]
      next if ['r','i','d','e','n'].include? trust # clearly invalid

      # If we're in --trust mode, we skip unknown uids.
      if options[:trust]
        next if !['f','m','u'].include?(trust)
      end

      uid = fields[9]
      good_uids << {:uid => uid, :trust => trust}
    end

    good_uids
  end
  
  # match up valid trusted uid with good owner if possible
  def self.find_good_owner uids_and_trust, owners
    good_owner = false

    uids_and_trust.each do |u|
      uid = u[:uid]
      email = if uid.include? "<"
                /<([^>]+)>/.match(uid)[1]
              else
                uid
              end

      if owners.include? email
        say add_color("Owner check indicates #{email} is owner per rubygems.org...", :green)
        good_owner = true
      end
    end

    good_owner
  end

  
end
