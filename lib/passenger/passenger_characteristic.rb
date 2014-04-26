module TaxiLearner
  class Passenger
    class Characteristic
      attr_reader :weight

      def initialize(value: 1, weight: 1, function: default_function)
        @value = value
        @weight = weight
        @function = function
      end

      def normalised_value
        @function.call(@value)
      end

    private

      def default_function
        ->(value) { 0.25 * value }
      end
    end
  end
end
