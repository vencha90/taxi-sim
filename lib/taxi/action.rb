module TaxiLearner
  class Taxi
    class Action
      attr_reader :type, :value, :units, :unit_cost

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

      def cost
        case @type
        when :wait
          @unit_cost
        when :offer
          @unit_cost
        when :drive
          @units * @unit_cost
        else
          0
        end
      end
    end
  end
end
