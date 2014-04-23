module TaxiLearner
  class World
    attr_reader :graph, :time

    def initialize(graph)
      @graph = graph
      @time = 0
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
      # if location.has_passenger?
      #   passenger = Passenger.new
      #   params[:passenger_destination] = passenger.destination
      # end
      Taxi.new(params)
    end  
  end
end
