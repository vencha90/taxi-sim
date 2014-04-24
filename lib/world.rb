module TaxiLearner
  class World
    attr_reader :graph, :time

    def initialize(graph:,
                   passenger_params:,
                   taxi_params:,
                   time_limit: 100000)
      @graph = graph
      @time = 0
      @passenger_params = passenger_params
      assign_taxi
    end

    def tick
      @time += 1
      action = @taxi.action
      if action
        if action.type == :offer && @passenger.accept_fare?(action.value)
          location = @passenger.destination
          set_new_passenger(location)
          reward = action.value - action.cost
          @taxi.tick!(reward: reward, location: location)
        else
          @taxi.tick!(reward: - action.cost)
        end
        @taxi.busy_for = action.cost
      else
        @taxi.tick!
      end
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
      @taxi = Taxi.new(params)
      set_new_passenger(location)
    end

    def set_new_passenger(location)
      if location.has_passenger?
        @passenger = Passenger.new(
          {world: self, location: location}.merge(@passenger_params) )
        @taxi.passenger_destination = @passenger.destination
      end
    end
  end
end
