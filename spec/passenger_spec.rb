describe Passenger do
  let(:graph) { double(random_vertex: 'destination_vertex') }
  let(:world) { double(graph: graph) }


  describe 'initialisation' do
    subject { Passenger.new(world: world,
       location: 'location_vertex',
       price: 'price',
       characteristics: ['characteristic']) }

    its(:characteristics) { should include('characteristic') }
    its(:characteristics) { should be_a_kind_of(Array) }
    its(:world) { should eq(world) }
    its(:location) { should eq('location_vertex') }
    its(:destination) { should eq('destination_vertex') }
    its(:price) { should eq('price') }
  end

  describe '#expected_fare' do
    subject { Passenger.new(world: world,
                            location: 'location_vertex',
                            price: 12) }
    it 'equals distance * price' do
      allow(graph).to receive(:distance)
                        .with('location_vertex', 'destination_vertex')
                        .and_return(5)
      expect(subject.expected_fare).to eq(60)
    end
  end

  describe '#initialise_characteristics' do
    it 'sets some characteristics'
  end

  describe '#probabilistic_value' do
    let(:char1) { double(weight: 0.5, normalised_value: 0.9) }
    let(:char2) { double(weight: 2, normalised_value: 0.5) }

    subject { Passenger.new(characteristics: [char1, char2], world: world) }
    it 'is calculated according to the formula' do
      expect(subject.probabilistic_value).to be_within(0.00000001).of(0.58)
    end
  end

  describe '#accept_fare?' do
    it 'is true if probability high'
    it 'is false if probability low'
  end
end
