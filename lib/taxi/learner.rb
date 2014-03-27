module TaxiLearner
  class Taxi
    class Learner
      DEFAULT_VALUE_ESTIMATE = 100
      attr_reader :value_estimates, :state, :visits

      def initialize(state:, environment:, discount_factor: 0.1,
                     step_size_function: nil, value_estimates: {},
                     epsilon: 0)
        @discount_factor = discount_factor
        @state = state
        @states = environment
        @visits = @states.map{ |state| [state, Hash.new] }.to_h
        @epsilon = epsilon

        @step_size_function = step_size_function || default_step_size_function
        @value_estimates = value_estimates
      end

      def act!(available_actions)
        initialise_action_estimates(available_actions)
        action = select_action(available_actions)

      end

      def update!(action:, new_state:, reward:) # Q-learning basic
        delta = reward + 
              @discount_factor * max_by_value(@value_estimates[new_state])[1] -
              @value_estimates[@state][action]
        @value_estimates[@state][action] += 
              delta * @step_size_function.call(@state, action)

        if @visits[@state][action].nil? 
          @visits[@state][action] = 1
        else
          @visits[@state][action] += 1
        end

        @state = new_state
      end

      def select_action(available_actions)
        if @value_estimates.nil? || 
                (state_actions = @value_estimates[@state]).nil?
          raise "no actions available at this agent's state"
        end
        available_in_state = state_actions.select do |k, v| 
          available_actions.include?(k) 
        end

        prob = @epsilon - rand()
        puts prob
        if prob >= 0
          action = max_by_value(available_in_state)
        else
          action = available_in_state.to_a.sample
        end
        action[0]
      end

    private

      def default_step_size_function
        Proc.new do |state|
          visits = @visits[state] 
          if visits > 0
            1.0 / visits
          else
            1.0
          end
        end
      end

      def max_by_value(hash)
        hash.max_by { |x| x[1] }
      end

      def initialise_action_estimates(actions)
        @value_estimates[@state] ||= Hash.new
        actions.each do |action|
          unless @value_estimates[@state].include?(action)
            @value_estimates[@state][action] = DEFAULT_VALUE_ESTIMATE
          end
        end
      end
    end
  end
end
