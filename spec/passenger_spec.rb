require 'plexus'

describe TaxiLearner::Passenger do
  describe 'initialisation' do
    subject { TaxiLearner::Passenger }

    it 'has a set of characteristics'

    it 'has a randomly chosen destination' do
      pending 'needs a vertex implementation first'
      expect(subject.new.destination).to be_a_kind_of(TaxiLearner::Graph::Vertex)
    end
  end

  describe '#accept_fare?' do
    it 'is true if probability high'
    it 'is false if probability low'
  end
end