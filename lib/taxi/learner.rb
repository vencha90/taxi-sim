module TaxiLearner
  class Taxi
    class Learner
      DEFAULT_VALUE_ESTIMATE = 100
      attr_reader :value_estimates, :state, :visits

      def initialize(state:, 
                     available_actions:,
                     discount_factor: 0.1,
                     step_size_function: nil, 
                     value_estimates: {},
                     epsilon: 0)
        @discount_factor = discount_factor
        @state = state
        @visits = { @state => Hash.new }
        @epsilon = epsilon

        @step_size_function = step_size_function || default_step_size_function
        @value_estimates = value_estimates
        initialise_action_estimates(@state, available_actions)
      end

      def act!(available_actions:, new_state:, reward:)
        initialise_action_estimates(new_state, available_actions)
        action = select_action()
        update!(action: action, new_state: new_state, reward: reward)
        action
      end

      def update!(action:, new_state:, reward:) # Q-learning basic
        @visits[@state] = {} if @visits[@state].nil?
        if @visits[@state][action].nil?
          @visits[@state][action] = 1
        else
          @visits[@state][action] += 1
        end
        delta = reward + 
              @discount_factor * max_by_value(@value_estimates[new_state])[1] -
              @value_estimates[@state][action]
        @value_estimates[@state][action] += 
              delta * @step_size_function.call(@state, action)

        @state = new_state
      end

      def select_action
        if @value_estimates.nil? || @value_estimates[@state].empty?
          raise RuntimeError, "no actions available at this agent's state"
        end
        state_actions = @value_estimates[@state]
        prob = @epsilon - rand()

        if prob >= 0
          action = max_by_value(state_actions)
        else
          action = state_actions.to_a.sample
        end
        action[0]
      end

    private

      def default_step_size_function
        Proc.new do |state, action|
          visits = @visits[state][action] 
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

      def initialise_action_estimates(state, actions)
        @value_estimates[state] ||= Hash.new
        actions.each do |action|
          unless @value_estimates[state].has_key?(action)
            @value_estimates[state][action] = DEFAULT_VALUE_ESTIMATE
          end
        end
      end
    end
  end
end
