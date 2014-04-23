module TaxiLearner
  class Passenger
    attr_reader :destination, :location, :price, :world, :characteristics

    def initialize(world:, location: nil, price: 0, characteristics: [])
      @world = world
      @location = location
      @destination = world.graph.random_vertex
      @price = price
      @characteristics = characteristics
    end

    def accept_fare?(fare)
      1 < ((expected_fare * probabilistic_value) / fare )
    end

  private
    def expected_fare
      distance = @world.distance(@location, @destination)
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
