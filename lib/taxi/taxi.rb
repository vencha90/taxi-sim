module TaxiLearner
  class Taxi
    include Logging
    attr_reader :fc, :vc, :prices, :reward, :action, :location, :passenger, :busy_for

    def initialize(world:,
                   location:,
                   reachable_destinations:,
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
      @passenger = nil
      @reachable_destinations = reachable_destinations
      @fc = fc
      @vc = vc
      @prices = prices
      @reward = reward

      @learner = learner || Taxi::Learner.new(state: set_state(@location),
                                    available_actions: available_actions)
      write_log(fc: @fc, vc: @vc, prices: @prices)
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
        @reward = params[:reward] || 0
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
      return nil if action.nil?
      learner_params = {}
      if action.type == :offer && passenger.accept_fare?(action.value)
        reward = action.value - action.cost
        action_length = @world.distance(location, passenger.destination)
        learner_params = { reward: reward, location: passenger.destination }
      elsif action.type == :offer || action.type == :wait
        action_length = 1
        learner_params = { reward: - @fc }
      elsif action.type == :drive
        action_length = @world.distance(location, action.value)
        learner_params = { reward: - action.cost, location: action.value }
      else 
        return nil
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
      passenger_destination = @passenger.nil? ? nil : @passenger.destination
      if busy?
        { reward: @reward,
          busy: busy?,
          destination: @location,
          busy_for: @busy_for,
          action: @action.type }
      else
        { reward: @reward,
          busy: busy?,
          location: @location,
          passenger_destination: passenger_destination }
      end
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
