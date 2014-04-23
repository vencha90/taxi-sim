module TaxiLearner
  class World
    attr_reader :graph, :time

    def initialize(graph:, expected_price: 1)
      @graph = graph
      @time = 0
      @expected_price = expected_price
      @taxi = assign_taxi
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

  private
    def assign_taxi
      location = @graph.random_vertex
      params = { world: self,
                 location: location,
                 reachable_destinations: @graph.vertices }
      if location.has_passenger?
        passenger = Passenger.new(world: self,
                                  location: location,
                                  price: @expected_price)
        params[:passenger_destination] = passenger.destination
      end
      Taxi.new(params)
    end  
  end
end
