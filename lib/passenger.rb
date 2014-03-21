module TaxiLearner
  class Passenger
    attr_reader :destination, :location, :price, :world, :characteristics

    def initialize(world:, location:, price:, characteristics: [])
      @world = world
      @location = location
      @destination = world.graph.random_vertex
      @price = price
      @characteristics = characteristics
    end

    def expected_fare
      distance = @world.graph.distance(@location, @destination)
      distance * price
    end

    def probabilistic_value
      sum = 0
      total_weight = 0
      @characteristics.each do |c|
        total_weight += c.weight
      end

      @characteristics.each do |c|
        relative_weight = c.weight / total_weight
        sum += relative_weight * c.normalised_value
      end
      sum
    end
  end
end
