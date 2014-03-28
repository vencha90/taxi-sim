module TaxiLearner
  class Taxi
    class State
      attr_reader :location, :destination
      def initialize(location, destination = nil)
        @location = location
        @destination = destination
      end

      def ==(other)
        @location == other.location && @destination == other.destination
      end

      alias eql? ==
    end
  end
end