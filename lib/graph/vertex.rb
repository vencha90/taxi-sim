module TaxiLearner
  class Graph
    class Vertex
      attr_reader :label, :passenger_probability
      alias_method :to_s, :label

      def initialize(label)
        @label = label.to_s
        @passenger_probability = rand(0.0..1.0)
      end

      def ==(another_vertex)
        self.class === another_vertex and
        self.label == another_vertex.label
      end

      alias eql? ==

      def hash
        self.label.hash
      end

      def <=>(another_vertex)
        self.to_s <=> another_vertex.to_s
      end

      def has_passenger?
        @passenger_probability > rand(0.0..1.0)
      end
    end
  end
end
