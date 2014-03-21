module TaxiLearner
  class Passenger
    attr_reader :destination

    def initialize(world)
      @destination = world.graph.random_vertex
    end
  end
end
