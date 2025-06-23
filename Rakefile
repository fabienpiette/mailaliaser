require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:performance) do |t|
  t.rspec_opts = '--tag performance'
end
RuboCop::RakeTask.new

task default: %i[rubocop spec]
task :bench => :performance
