require 'rubygems'
require 'bundler/setup'
require 'require_all'
require 'yaml'

require_all 'lib'

module TaxiLearner
  class Runner
    attr_reader :world

    def initialize(args = nil)
      raise(ArgumentError, 'please specify a file for input') if args.nil?
      parser = TaxiLearner::FileParser.new(args.first)
      graph = TaxiLearner::Graph.new(parser.graph_adjacency_matrix)
      world_params = { graph: graph, 
                       passenger_params: parser.passenger,
                       taxi_params: parser.taxi }
      world_params[:time_limit] = parser.time_limit unless parser.time_limit.nil? 
      @world = TaxiLearner::World.new(world_params)
    end

  private

  end
end
