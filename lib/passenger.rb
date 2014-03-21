module TaxiLearner
  class Passenger
    attr_reader :destination, :location, :price, :world

    def initialize(world:, location:, price:)
      @world = world
      @location = location
      @destination = world.graph.random_vertex
      @price = price
    end

    def expected_fare
      distance = @world.graph.distance(@location, @destination)
      distance * price
    end
  end
end
