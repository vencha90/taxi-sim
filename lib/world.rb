module TaxiLearner
  class World
    include Logging
    attr_reader :graph, :time, :passenger

    DEFAULT_BENCHMARK_PRICE = 10

    def initialize(graph:,
                   passenger_params:,
                   taxi_params:,
                   time_limit: 100000)
      @graph = graph
      @time = 0
      @time_limit = time_limit
      @taxi_params = taxi_params
      @passenger_params = passenger_params
      @taxi = Taxi.new(get_taxi_params)
      write_log(time: @time, time_limit: @time_limit)
    end

    def run_simulation
      @time_limit.times { tick }
      benchmark = get_benchmark_price
      @taxi = Taxi.new(get_taxi_params.merge(prices: benchmark))
      @time_limit.times { tick }
    end

    def tick
      @passenger = set_new_passenger(@taxi.location)
      @taxi.act(@passenger)

      @time += 1
      write_log(time: @time)
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
      benchmark = @taxi_params[:benchmark_price] || DEFAULT_BENCHMARK_PRICE
      [benchmark]
    end

    def get_taxi_params
      location = @graph.random_vertex
      params = { world: self,
                 location: location,
                 reachable_destinations: @graph.vertices }
      prices = @taxi_params[:prices]
      params.merge({prices: prices}) unless prices.nil?
    end

    def set_new_passenger(location)
      if location.has_passenger?
        Passenger.new(
          {world: self, location: location}.merge(@passenger_params) )
      else
        nil
      end
    end
  end
end
