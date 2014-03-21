module TaxiLearner
  module Graph
    class Vertex
      attr_reader :label, :passenger_probability
      alias_method :to_s, :label

      def initialize(label)
        @label = label.to_s
        @passenger_probability = rand(0.1..0.9)
      end

      def ==(another_vertex)
        self.to_s == another_vertex.to_s
      end

      def <=>(another_vertex)
        self.to_s <=> another_vertex.to_s
      end
    end
  end
end