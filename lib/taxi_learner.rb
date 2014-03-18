require 'rubygems'
require 'bundler/setup'
require 'require_all'
require 'yaml'

require_all 'lib'

module TaxiLearner
  class Runner
    attr_reader :yaml, :graph

    def initialize(args = nil)
      raise(ArgumentError, 'please specify a file for input') if args.nil?
      parser = TaxiLearner::FileParser.new(args.first)
      @yaml = parser.graph_adjacency_matrix
    end

  private

  end
end
