require 'rake/testtask'
require 'rubygems/package_task'

GEMSPEC = Gem::Specification.load('rubygems-openpgp.gemspec')

Gem::PackageTask.new(GEMSPEC) do |t|
  t.need_zip = false
  t.need_tar = false
end

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test
