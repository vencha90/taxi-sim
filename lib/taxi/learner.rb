module TaxiLearner
  class Taxi
    class Learner
      attr_reader :value_estimates, :state, :visits

      def initialize(state:, environment:, discount_factor: 0.1,
                     step_size_function: nil, value_estimates: nil)
        @discount_factor = discount_factor
        @state = state
        @states = environment
        @visits = @states.map{ |state| [state, Hash.new] }.to_h
        @epsilon = 0

        @step_size_function = step_size_function || default_step_size_function
        @value_estimates = value_estimates
      end

      def act!(actions)

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

      def select_action
        if @value_estimates.nil? || (action_hash = @value_estimates[@state]).nil?
          raise "no actions available at this agent's state"
        end
        prob = @epsilon - rand()
        if prob >= 0
          action = max_by_value(action_hash)
        else
          action = action_hash.to_a.sample
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
    end
  end
end