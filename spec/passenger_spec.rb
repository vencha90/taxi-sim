require 'plexus'

describe TaxiLearner::Passenger do
  let(:graph) { double(random_vertex: 'destination_vertex') }
  let(:world) { double(graph: graph) }
  subject { TaxiLearner::Passenger.new(world: world,
                                       location: 'location_vertex',
                                       price: 12) }

  describe 'initialisation' do
    it 'has a set of characteristics'
    its(:world) { should eq(world) }
    its(:location) { should eq('location_vertex') }
    its(:destination) { should eq('destination_vertex') }
    its(:price) { should eq(12) }
  end

  describe '#expected_fare' do
    it 'equals dixtance * price' do
      allow(graph).to receive(:distance)
                        .with('location_vertex', 'destination_vertex')
                        .and_return(5)
      expect(subject.expected_fare).to eq(60)
    end
  end

  describe '#accept_fare?' do
    it 'is true if probability high'
    it 'is false if probability low'
  end
end
