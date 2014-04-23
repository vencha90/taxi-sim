module TaxiLearner
  class World
    attr_reader :graph, :time

    def initialize(graph)
      @graph = graph
      @time = 0
      @taxi = TaxiLearner::Taxi.new(world: self,
        location: @graph.random_vertex,
        reachable_destinations: @graph.vertices)
    end

    def tick
      @time += 1
    end

    def reachable_destinations(*args)
      # Assumes a connected graph
      @graph.vertices
    end

    def distance(a, b)
      @graph.distance(a, b)
    end
  end
end
