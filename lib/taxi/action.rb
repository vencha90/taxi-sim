module TaxiLearner
  class Taxi
    class Action
      attr_reader :type, :value, :units, :fc, :vc

      MINIMUM_COST = 1

      def initialize(type:, value: nil, units: 0, fc: 0, vc: 0)
        @type = type
        @value = value
        @units = units
        @fc = fc
        @vc = vc
      end

      def == (other)
        @type == other.type && 
          @value == other.value && 
          @units == other.units &&
          @fc == other.fc &&
          @vc == other.vc
      end

      alias eql? ==

      def cost(accepted: false)
        case @type
        when :wait
          cost = @fc
        when :offer
          if accepted
            cost = @units * (@fc + @vc)
          else
            cost = @fc
          end
        when :drive
          cost = @units * (@fc + @vc)
        else
          cost = 0
        end
        cost < MINIMUM_COST ? MINIMUM_COST : cost
      end
    end
  end
end
