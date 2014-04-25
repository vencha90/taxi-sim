require 'logger'

module TaxiLearner
  module Logging
    def logger
      Logging.logger
    end

    def write_log(**args)
      string_args = ''
      args.each do |arg|
        if arg.respond_to?(:map)
          arg.map! { |a| a.to_s }
        end
        string_args += arg.to_s
      end
      logger.puts(string_args)
    end

    def self.logger
      @file ||= File.new('logs/simulation.log', 'w')
    end
  end
end
