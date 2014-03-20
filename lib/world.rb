module TaxiLearner
  class World
    attr_reader :graph, :time

    def initialize(graph)
      @graph = graph
      @time = 0
    end

    def tick
      @time += 1
    end
  end
end