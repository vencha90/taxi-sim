module TaxiLearner
  class Taxi
    class Action
      attr_reader :type, :value, :units, :unit_cost

      MINIMUM_COST = 1

      def initialize(type:, value: nil, units: 0, unit_cost: 0)
        @type = type
        @value = value
        @units = units
        @unit_cost = unit_cost
      end

      def == (other)
        @type == other.type && 
          @value == other.value && 
          @units == other.units &&
          @unit_cost == other.unit_cost
      end

      alias eql? ==

      def cost(accepted: false)
        case @type
        when :wait
          cost = @unit_cost
        when :offer
          if accepted
            cost = @units * @unit_cost
          else
            cost = @unit_cost
          end
        when :drive
          cost = @units * @unit_cost
        else
          cost = 0
        end
        cost < MINIMUM_COST ? MINIMUM_COST : cost
      end
    end
  end
end
