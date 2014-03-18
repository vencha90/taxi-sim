require 'yaml'

module TaxiLearner
  class FileParser
    REQUIRED_VARIABLES = %w{graph}

    def initialize(args)
      @yaml = Psych.parse_file(args).to_ruby
      REQUIRED_VARIABLES.each do |var|
        if @yaml[var].nil?
          raise ArgumentError, "'#{var}' not found in input file"
        end
      end
    end

    def graph_adjacency_matrix
      self.class.graph_adjacency_matrix(@yaml)
    end

    def self.graph_adjacency_matrix(yaml)
      matrix = yaml['graph']
      raise ArgumentError, "bad input graph matrix" unless matrix.respond_to?(:map)
      matrix.map!.with_index do |row, index|
        row.split(',').map! { |item| item.to_i }
      end
      matrix
    end
  end
end