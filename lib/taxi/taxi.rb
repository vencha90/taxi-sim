module TaxiLearner
  class Taxi
    attr_reader :fc, :vc, :prices

    def initialize(location:, world:, fc: 1, vc: 1, 
                   learner: nil, prices: 1..20)
      @fc = fc
      @vc = vc
      @busy_for = 0
      @location = location
      @world = world
      @prices = prices
      environment = @world.graph.vertices
      @learner = learner || Taxi::Learner.new(state: @location,
                                    environment: environment,
                                    available_actions: available_actions)
    end

    def busy?
      @busy_for > 0
    end

    def act!
      @learner.act!
    end

    def tick!
    end

    def available_actions(location = @location)
      actions = [Taxi::Action.new(:wait)]
      @world.reachable_destinations(location).each do |destination|
        actions << Taxi::Action.new(:drive, destination)
      end
      if location.has_passenger?
        @prices.each do |price|
          actions << Taxi::Action.new(:offer, price)
        end
      end
      actions
    end
  end
end
