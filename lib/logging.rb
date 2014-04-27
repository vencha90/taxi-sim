require 'logger'

module TaxiLearner
  module Logging
    def logger
      Logging.logger
    end

    def summary
      Logging.summary
    end

    def write_log(**args)
      logger.puts(process_args args)
    end

    def write_summary(**args)
      summary.puts(process_args args)
    end

    def self.logger
      @main_file ||= File.new('logs/simulation.log', 'w')
    end

    def self.summary
      @summary_file ||= File.new('logs/summary.log', 'w')
    end

    private

    def process_args(**args)
      string_args = ''
      args.each do |arg|
        if arg.respond_to?(:map)
          arg.map! { |a| a.to_s }
        end
        string_args += arg.to_s
      end
      string_args
    end
  end
end
