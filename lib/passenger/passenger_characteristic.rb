module TaxiLearner
  class Passenger
    class Characteristic
      attr_reader :weight

      VALUE = 1
      WEIGHT = 1
      DEFAULT_MODIFIER = 1

      def initialize(value: VALUE,
                     weight: WEIGHT,
                     function: default_function)
        @value = value
        @weight = weight
        @function = function
      end

      def normalised_value
        @function.call(@value)
      end

    private

      def default_function
        ->(value) { DEFAULT_MODIFIER * value }
      end
    end
  end
end
