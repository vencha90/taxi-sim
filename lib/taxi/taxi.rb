module TaxiLearner
  class Taxi
    include Logging
    attr_reader :action,
                :busy_for,
                :fc,
                :location,
                :passenger,
                :prices,
                :reward,
                :total_profit,
                :vc

    FIXED_COST = 1
    VARIABLE_COST = 1
    PRICES = 1..20
    DEFAULT_ACTION_LENGTH = 1

    def initialize(world:,
                   location:,
                   reachable_destinations:,
                   fc: FIXED_COST,
                   vc: VARIABLE_COST,
                   prices: PRICES,
                   reward: 0,
                   learner: nil)
      @all_actions = []
      @all_states = []
      @busy_for = 0
      @action = nil
      @passenger = nil
      @total_profit = 0

      @world = world
      @location = location
      @reachable_destinations = reachable_destinations
      @fc = fc
      @vc = vc
      @prices = prices
      @reward = reward

      @learner = learner || Taxi::Learner.new(state: set_state(@location),
                                    available_actions: available_actions)
      write_summary(fc: @fc, vc: @vc, prices: @prices)
    end

    def busy?
      @busy_for > 0
    end

    def act(passenger = nil)
      @busy_for -= 1 if self.busy?
      unless self.busy?
        params = process_action(location: @location,
                                action: @action,
                                passenger: passenger)
        @reward = params[:reward] || -@fc
        @total_profit += @reward
        @location = params[:location] || @location
        @busy_for = params[:busy_for]
        @passenger = passenger
        write_log(log_params)
        @action = @learner.act!(available_actions: available_actions,
                                new_state: set_state(@location, @passenger),
                                reward: @reward)
      end
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
      unless @passenger.nil? || @passenger.destination.nil?
        @prices.each do |price|
          actions << find_or_create_action(type: :offer, value: price, unit_cost: @fc)
        end
      end
      actions
    end

    def process_action(location: , action:, passenger:)
      action_length = DEFAULT_ACTION_LENGTH
      learner_params = { busy_for: action_length }
      return learner_params if action.nil?

      if action.type == :offer && passenger && passenger.accept_fare?(action.value)
        reward = action.value - action.cost
        action_length = @world.distance(location, passenger.destination)
        learner_params = { reward: reward, location: passenger.destination }
      elsif action.type == :offer || action.type == :wait
        action_length = DEFAULT_ACTION_LENGTH
        learner_params = { reward: - @fc }
      elsif action.type == :drive
        action_length = @world.distance(location, action.value)
        action_length = DEFAULT_ACTION_LENGTH if action_length < DEFAULT_ACTION_LENGTH
        learner_params = { reward: - action.cost, location: action.value }
      end
      learner_params[:busy_for] = action_length
      learner_params
    end

    def set_state(location, passenger = nil)
      if passenger.nil? || passenger.destination.nil?
        temp = Taxi::State.new(location)
      else
        temp = Taxi::State.new(location, passenger.destination)
      end
      find_or_create(temp, @all_states)
    end

  private

    def log_params
      action_type = @action.nil? ? nil : @action.type
      { reward: @reward,
        location: @location,
        busy_for: @busy_for,
        action: action_type
      }
    end

    def find_or_create_action(**params)
      find_or_create(Taxi::Action.new(params), @all_actions)
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
