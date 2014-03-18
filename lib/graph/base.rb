require 'plexus'

module TaxiLearner
  module Graph
    class Base
      attr_reader :graph

      def initialize(matrix)
        @graph = initialize_graph(matrix)
      end

    private 
      def initialize_graph(matrix)
        matrix_length = matrix.length
        e = -> { raise ArgumentError, "bad matrix dimensions: #{matrix.to_s}" }
        e.call if matrix_length < 1
        graph = Plexus::Digraph.new
        matrix.each.with_index do |row, row_index|
          e.call unless row.length == matrix_length
          row.each.with_index do |column, column_index|
            next if column == 0
            next if row_index == column_index #ignore self-loop
            graph.add_edge!(row_index + 1, column_index + 1, column)
          end
        end
        graph
      end
    end
  end
end
