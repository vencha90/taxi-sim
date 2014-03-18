module TaxiLearner
  module Graph
    class Base
      def initialize(matrix)
        initialize_graph(matrix)
      end

    private 
      def initialize_graph(matrix)
        matrix_length = matrix.length
        e = -> { raise ArgumentError, "bad matrix dimensions: #{matrix.to_s}" }
        e.call if matrix_length < 1
        matrix.each do |row|
          e.call unless row.length == matrix_length
        end
      end
    end
  end
end
