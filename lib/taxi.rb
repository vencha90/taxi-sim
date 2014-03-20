module TaxiLearner
  class Taxi
    attr_reader :fc, :vc

    def initialize(fc: 0, vc: 0)
      @fc = fc
      @vc = vc
      @busy_for = 0
    end

    def busy?
      @busy_for > 0
    end

    def act
    end

    def tick
    end
  end
end