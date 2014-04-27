require "rspec/core/rake_task"

task default: :run

desc "Run taxi learner simulation using a file for input"
task :run, [:path] do |t, args|
  if args.path.nil? || args.path.strip.nil?
    puts "please specify a path by adding [path/to/some/file]"
  else
    ruby "bin/taxi_learner #{args.path}"
    puts 'Task completed. Please see log files for results'
  end
end

RSpec::Core::RakeTask.new(:spec)
