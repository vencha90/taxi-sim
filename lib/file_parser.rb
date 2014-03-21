require 'yaml'

module TaxiLearner
  class FileParser
    def initialize(args)
      @yaml = Psych.parse_file(args).to_ruby
    end

    def graph_adjacency_matrix(yaml = @yaml)
      matrix = yaml['graph']
      raise ArgumentError, "no input graph" if matrix.nil?
      raise ArgumentError, "bad input graph matrix" unless matrix.respond_to?(:map)
      matrix.map!.with_index do |row, index|
        row.split(',').map! { |item| item.to_i }
      end
      matrix
    end

    def passenger(yaml = @yaml)
      details = yaml['passenger']
      raise ArgumentError, 'no input passenger details' if details.nil?
      price = details['price']
      raise ArgumentError, 'no input passenger expected price' if price.nil?
      { price: price.to_i }
    end
  end
end