# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  gem 'rubygems-tasks', '~> 0.2.4'
  require 'rubygems/tasks'

  Gem::Tasks.new
rescue LoadError => e
  warn e.message
  warn "Run `gem install rubygems-tasks` to install Gem::Tasks."
end

begin
  gem 'rspec', '~> 2.13'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end

task :test    => :spec
task :default => :spec

begin
  gem 'yard', '~> 0.8.5.2'
  require 'yard'

  YARD::Rake::YardocTask.new
rescue LoadError => e
  task :yard do
    abort "Please run `gem install yard` to install YARD."
  end
end
task :doc => :yard

begin
  gem 'yardstick', '~> 0.9.5'

  require 'yardstick/rake/measurement'

  Yardstick::Rake::Measurement.new(:yardstick_measure) do |measurement|
    measurement.output = 'doc/measurement_report.txt'
  end

  require 'yardstick/rake/verify'

  Yardstick::Rake::Verify.new do |verify|
    verify.threshold = 100
  end
rescue LoadError => e
  task :yardstick do
    abort "Please run `gem install yardstick` to install yardstick."
  end
end
