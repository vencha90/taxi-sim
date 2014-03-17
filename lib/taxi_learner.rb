require 'rubygems'
require 'bundler/setup'
require 'require_all'

require_all 'lib'

class TaxiLearner
  attr_reader :file

  def initialize(argv)
    @file = parse_file(ARGV.first)
  end

private

  def parse_file(path)
    path
  end
end
