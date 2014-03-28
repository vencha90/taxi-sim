module TaxiLearner
  class Taxi
    attr_reader :fc, :vc, :prices

    def initialize(location:,
                   destination: nil,
                   reachable_destinations:,
                   fc: 1,
                   vc: 1,
                   learner: nil,
                   prices: 1..20)
      @fc = fc
      @vc = vc
      @busy_for = 0
      @location = location
      @destination = destination
      @reachable_destinations = reachable_destinations
      @prices = prices
      @learner = learner || Taxi::Learner.new(state: set_state,
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

  private

    def available_actions
      actions = [Taxi::Action.new(:wait)]
      @reachable_destinations.each do |destination|
        actions << Taxi::Action.new(:drive, destination)
      end
      unless @destination.nil?
        @prices.each do |price|
          actions << Taxi::Action.new(:offer, price)
        end
      end
      actions
    end

    def set_state
      if @destination.nil?
        Taxi::State.new(@location)
      else
        Taxi::State.new(@location, @destination)
      end
    end
  end
end
