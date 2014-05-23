require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new
rescue LoadError
  puts "RSpec is not installed, skipping."
end

task :default => :spec