module TaxiLearner
  class Passenger
    include Logging
    attr_reader :destination, :location, :price, :world, :characteristics

    PRICE = 1
    THRESHOLD = 0.75
    RANDOMNESS = 0.75..1.0

    def initialize(world:, location: nil, price: PRICE,
                   characteristics: default_characteristics)
      @world = world
      @location = location
      @destination = world.graph.random_vertex(location)
      @price = price
      @characteristics = characteristics
    end

    def accept_fare?(fare)
      accept = rand(RANDOMNESS) * THRESHOLD < ((expected_fare * probabilistic_value) / fare )
      str = accept ? 'accepted' : 'declined'
      write_log(passenger: str,
          fare: fare,
          destination: @destination)
      accept
    end

    def expected_fare
      distance = @world.distance(@location, @destination)
      distance * @price
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

  private

    def default_characteristics
      [Passenger::Characteristic.new]
    end
  end
end
