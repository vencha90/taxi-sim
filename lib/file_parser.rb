require 'yaml'

module TaxiLearner
  class FileParser
    def initialize(args)
      @yaml = Psych.parse_file(args).to_ruby
    end

    def graph_adjacency_matrix
      matrix = @yaml['graph']
      matrix.map! do |row|        
        row.split(',').map! { |item| item.to_i }
      end
      matrix
    end
  end
end