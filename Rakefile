require "rspec/core/rake_task"

task default: :run

desc "Run taxi learner simulation using a file for input"
task :run, [:path] do |t, args|
  if args.path.strip.nil?
    puts "please specify a path by adding [path/to/some/file]"
  else
    ruby "bin/taxi_learner #{args.path}"
  end
end

RSpec::Core::RakeTask.new(:spec)
