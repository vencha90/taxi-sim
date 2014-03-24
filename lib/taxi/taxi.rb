module TaxiLearner
  class Taxi
    attr_reader :fc, :vc

    def initialize(fc: 0, vc: 0, learner: nil)
      @fc = fc
      @vc = vc
      @busy_for = 0
      @learner = learner || Taxi::Learner.new
    end

    def busy?
      @busy_for > 0
    end

    def act!
      @learner.act!
    end

    def tick!
    end
  end
end