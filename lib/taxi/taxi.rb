module TaxiLearner
  class Taxi
    attr_accessor :passenger_destination
    attr_reader :fc, :vc, :prices, :reward, :action

    def initialize(location:,
                   passenger_destination: nil,
                   reachable_destinations:,
                   fc: 1,
                   vc: 1,
                   learner: nil,
                   prices: 1..20,
                   reward: 0)
      @fc = fc
      @vc = vc
      @busy_for = 0
      @location = location
      @passenger_destination = passenger_destination
      @reachable_destinations = reachable_destinations
      @prices = prices
      @learner = learner || Taxi::Learner.new(state: set_state,
                                    available_actions: available_actions)
      @reward = reward
      @action = nil
    end

    def busy?
      @busy_for > 0
    end

    def act!
      last_profit = get_action_profit(@action)
      @action = @learner.act!(available_actions: available_actions,
                              new_state: @state,
                              reward: @reward + last_profit)
    end

    def tick!(reward: 0, state: @state)
      @busy_for =- 1 if busy?
      @reward = reward
      act!
    end

  private

    def available_actions
      actions = [Taxi::Action.new(:wait)]
      @reachable_destinations.each do |destination|
        actions << Taxi::Action.new(:drive, destination)
      end
      unless @passenger_destination.nil?
        @prices.each do |price|
          actions << Taxi::Action.new(:offer, price)
        end
      end
      actions
    end

    def set_state
      if @passenger_destination.nil?
        Taxi::State.new(@location)
      else
        Taxi::State.new(@location, @passenger_destination)
      end
    end

    def get_action_profit(action)
      0
    end
  end
end
