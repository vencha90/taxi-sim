require "rspec/core/rake_task"

task default: :spec

desc "Run the taxi learner simulation"
task :run do
  ruby "lib/taxi_learner.rb"
end

RSpec::Core::RakeTask.new(:spec)
