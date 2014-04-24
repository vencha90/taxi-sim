describe Passenger do
  let(:graph) { double(random_vertex: 'destination_vertex') }
  let(:world) { double(graph: graph) }


  describe 'initialisation' do
    subject { Passenger.new(world: world,
       location: 'location_vertex',
       price: 'price') }

    its(:characteristics) { should be_a_kind_of(Array) }
    its(:world) { should eq(world) }
    its(:location) { should eq('location_vertex') }
    its(:destination) { should eq('destination_vertex') }
    its(:price) { should eq('price') }

    it 'instantiates a characteristic' do
      expect(Passenger::Characteristic).to receive(:new).once
      subject
    end
  end

  describe '#expected_fare' do
    subject { Passenger.new(world: world,
                            location: 'location_vertex',
                            price: 12) }
    it 'equals distance * price' do
      allow(world).to receive(:distance)
                        .with('location_vertex', 'destination_vertex')
                        .and_return(5)
      expect(subject.send(:expected_fare)).to eq(60)
    end
  end

  describe '#probabilistic_value' do
    let(:char1) { double(weight: 0.5, normalised_value: 0.9) }
    let(:char2) { double(weight: 2, normalised_value: 0.5) }

    subject { Passenger.new(characteristics: [char1, char2], world: world) }
    it 'is calculated according to the formula' do
      expect(subject.send(:probabilistic_value)).to be_within(0.00000001).of(0.58)
    end
  end

  describe '#accept_fare?' do
    subject { Passenger.new(world: world) }
    before do
      subject.stub(:expected_fare).and_return(5)
      subject.stub(:probabilistic_value).and_return(0.5) # ==> Q = 2.5
    end

    it 'is true if offered fare too low' do
      expect(subject.accept_fare?(2.4)).to be_true
    end

    it 'is false if offered fare too high' do
      expect(subject.accept_fare?(2.6)).to be_false
    end
  end
end
