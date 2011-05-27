require 'open3'
require 'tempfile'

module Gem::OpenPGP
  def self.openpgp_available?
    `gpg --version`
    $? == 0
  rescue
    false
  end

  def self.detach_sign data, key_id=nil
    key_flag = ""
    key_flag = "-u #{key_id}" if key_id
    cmd = "gpg #{key_flag} --detach-sign --armor"
    exit_status = nil
    sig,err = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.write data
      stdin.close
      exit_status = wait_thr.value
      [stdout.read(), stderr.read()]
    end

    raise "gpg error #{err}" if exit_status != 0

    sig
  end

  def self.verify data, sig
    data_file = Tempfile.new("rubygems_data")
    data_file.write(data)
    data_file.close

    sig_file = Tempfile.new("rubygems_sig")
    sig_file.write(sig)
    sig_file.close

    cmd = "gpg --verify #{sig_file.path} #{data_file.path}"
    exit_status = nil
    res, err = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      exit_status = wait_thr.value
      [ stdout.read(), stderr.read() ]
    end

    puts err
    puts res

    raise "gpg encountered errors! #{err}" if exit_status != 0
  end
end
