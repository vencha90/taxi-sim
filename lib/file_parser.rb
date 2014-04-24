require 'yaml'

module TaxiLearner
  class FileParser
    def initialize(args)
      @yaml = Psych.parse_file(args).to_ruby
    end

    def graph_adjacency_matrix(yaml = @yaml)
      matrix = yaml['graph']
      raise ArgumentError, "no input graph" if matrix.nil?
      raise ArgumentError, "bad input graph matrix" unless matrix.respond_to?(:map)
      matrix.map!.with_index do |row, index|
        row.split(',').map! { |item| item.to_i }
      end
      matrix
    end

    def passenger(yaml = @yaml)
      details = yaml['passenger']
      raise ArgumentError, 'no input passenger details' if details.nil?
      price = details['price']
      raise ArgumentError, 'no input passenger expected price' if price.nil?
      { price: price.to_i }
    end

    def taxi(yaml = @yaml)
      params = {}
      taxi_params = yaml['taxi']
      raise ArgumentError, 'no input taxi details' if taxi_params.nil?
      prices = parse_prices(taxi_params['prices'])
      params[:prices] = prices unless prices.nil?
      benchmark_price = parse_benchmark_price(taxi_params['benchmark_price'])
      params[:benchmark_price] = benchmark_price unless benchmark_price.nil?
      params
    end

  private
    def parse_prices(input)
      return nil if input.nil? || input.empty?
      if input.include?('..')
        prices = Range.new(*input.split("..").map(&:to_i))
      elsif input =~ /\D/
        raise ArgumentError, 'bad price range entered for taxi'
      else
        prices = [input.to_i]
      end
      prices
    end

    def parse_benchmark_price(input)
      return nil if input.nil?
      raise ArgumentError, 'bad benchmark price entered for taxi' if input =~ /\D/
      input.to_i
    end
  end
end
