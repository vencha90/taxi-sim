module TaxiLearner
  class Taxi
    attr_reader :fc, :vc

    def initialize(location:, world:, fc: 1, vc: 1, learner: nil)
      @fc = fc
      @vc = vc
      @busy_for = 0
      @learner = learner || Taxi::Learner.new(state: location, environment: world)
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