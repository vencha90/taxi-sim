require 'plexus'

describe TaxiLearner::Passenger do
  let(:graph) { double(random_vertex: 'some_vertex') }
  let(:world) { double(graph: graph) }
  subject { TaxiLearner::Passenger.new(world) }

  describe 'initialisation' do
    it 'has a set of characteristics'

    it 'has a randomly chosen destination from the world' do
      expect(subject.destination).to eq('some_vertex')
    end
  end

  describe '#accept_fare?' do
    it 'is true if probability high'
    it 'is false if probability low'
  end
end
