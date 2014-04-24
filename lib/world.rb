module TaxiLearner
  class World
    attr_reader :graph, :time

    DEFAULT_BENCHMARK_PRICE = 10

    def initialize(graph:,
                   passenger_params:,
                   taxi_params:,
                   time_limit: 100000)
      @graph = graph
      @time = 0
      @time_limit = time_limit
      @input_taxi_params = taxi_params
      @passenger_params = passenger_params
      assign_taxi
    end

    def run_simulation
      @time_limit.times { tick }
      benchmark = get_benchmark_price
      @taxi = Taxi.new(get_taxi_params.merge(prices: benchmark))
      @time_limit.times { tick }
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
    def get_benchmark_price
      benchmark = @input_taxi_params[:benchmark_price]
      benchmark = DEFAULT_BENCHMARK_PRICE if benchmark.nil?
      [benchmark]
    end

    def get_taxi_params
      location = @graph.random_vertex
      params = { world: self,
                 location: location,
                 reachable_destinations: @graph.vertices }
      prices = @input_taxi_params[:prices]
      params.merge({prices: prices}) unless prices.nil?
    end

    def assign_taxi(prices = nil)
      @taxi = Taxi.new(get_taxi_params)
      set_new_passenger(get_taxi_params[:location])
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
