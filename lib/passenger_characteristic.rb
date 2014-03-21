module TaxiLearner
  class PassengerCharacteristic
    attr_reader :weight

    def initialize(value: 0, weight: 0, function: nil)
      @value = value
      @weight = weight
      @function = function
    end

    def normalised_value
      @function.call(@value)
    end
  end
end
