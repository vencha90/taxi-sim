module TaxiLearner
  class Taxi
    attr_accessor :passenger_destination, :busy_for
    attr_reader :fc, :vc, :prices, :reward, :action, :location

    def initialize(world:,
                   location:,
                   reachable_destinations:,
                   passenger_destination: nil,
                   fc: 1,
                   vc: 1,
                   prices: 1..20,
                   reward: 0,
                   learner: nil)
      @all_actions = []
      @all_states = []
      @busy_for = 0
      @action = nil

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
    end

    def busy?
      @busy_for > 0
    end

    def act!
      last_profit = @action.nil? ? 0 : @action.cost
      @action = @learner.act!(available_actions: available_actions,
                              new_state: set_state,
                              reward: @reward + last_profit)
    end

    def tick!(reward: 0, location: @location)
      @busy_for =- 1 if busy?
      @reward = reward
      @location = location
      act!
    end

    def available_actions
      actions = [find_or_create_action(type: :wait, unit_cost: @fc)]
      @reachable_destinations.each do |destination|
        distance = @world.distance(@location, destination)
        actions << find_or_create_action(type: :drive, 
                                    value: destination,
                                    units: distance,
                                    unit_cost: @fc + @vc)
      end
      unless @passenger_destination.nil?
        @prices.each do |price|
          actions << find_or_create_action(type: :offer, value: price, unit_cost: @fc)
        end
      end
      actions
    end

  private
    def find_or_create_action(**params)
      find_or_create(Taxi::Action.new(params), @all_actions)
    end

    def set_state
      if @passenger_destination.nil?
        temp = Taxi::State.new(@location)
      else
        temp = Taxi::State.new(@location, @passenger_destination)
      end
      find_or_create(temp, @all_states)
    end

    def find_or_create(object, collection)
      found = nil
      collection.each do |item|
        if object == item
          found = item
          break
        end
      end
      if found.nil?
        collection << object
        object
      else
        found
      end
    end
  end
end
