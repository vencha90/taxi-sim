module TaxiLearner
  class Taxi
    class Action
      attr_reader :type, :value, :units

      def initialize(type:, value: nil, units: nil)
        @type = type
        @value = value
        @units = units
      end

      def == (other)
        @type == other.type && @value == other.value && @units == other.units
      end

      alias eql? ==

      def cost(cost = 0)
        case @type
        when :wait
          cost
        when :offer
          cost
        when :drive
          @units * cost
        else
          0
        end
      end
    end
  end
end
