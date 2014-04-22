module TaxiLearner
  class Taxi
    attr_accessor :passenger_destination
    attr_reader :fc, :vc, :prices, :reward, :action

    def initialize(world:,
                   location:,
                   reachable_destinations:,
                   passenger_destination: nil,
                   fc: 1,
                   vc: 1,
                   prices: 1..20,
                   reward: 0,
                   learner: nil)
      @world = world
      @location = location
      @passenger_destination = passenger_destination
      @reachable_destinations = reachable_destinations
      @fc = fc
      @vc = vc
      @prices = prices
      @reward = reward

      @learner = learner || Taxi::Learner.new(state: set_state,
                                    available_actions: available_actions)
      @busy_for = 0
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
      actions = [Taxi::Action.new(type: :wait)]
      @reachable_destinations.each do |destination|
        distance = @world.distance(@location, destination)
        actions << Taxi::Action.new(type: :drive, 
                                    value: destination,
                                    units: distance)
      end
      unless @passenger_destination.nil?
        @prices.each do |price|
          actions << Taxi::Action.new(type: :offer, value: price)
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
