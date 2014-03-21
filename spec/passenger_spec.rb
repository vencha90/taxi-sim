describe Passenger do
  let(:graph) { double(random_vertex: 'destination_vertex') }
  let(:world) { double(graph: graph) }
  let(:characteristic) { double(weight: 0.5, normalised_value: 0.9) }
  subject { TaxiLearner::Passenger.new(world: world,
     location: 'location_vertex',
     price: 12,
     characteristics: [characteristic]) }

  describe 'initialisation' do
    its(:characteristics) { should include(characteristic) }
    its(:characteristics) { should be_a_kind_of(Array) }
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

  describe '#probabilistic_value' do
    it 'is calculated according to the formula' do
      expect(subject.probabilistic_value).to eq(0.9)
    end
  end

  describe '#accept_fare?' do
    it 'is true if probability high'
    it 'is false if probability low'
  end
end
