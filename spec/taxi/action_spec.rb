describe Taxi::Action do
  subject { Taxi::Action.new(type: 'type') }
  describe 'initialisation' do
    subject { Taxi::Action }
    it 'assigns type' do
      expect(subject.new(type: 'type').type).to eq('type')
    end

    it 'assigns value' do
      expect(subject.new(type: nil, value: 'value').value).to eq('value')
    end

    it 'assigns units' do
      expect(subject.new(type: nil, units: 'dist').units).to eq('dist')
    end
  end

  describe '#==' do
    subject { Taxi::Action.new(type: 'type', value: 'value', units: 'units') }
    let(:equal_action) { Taxi::Action.new(type: 'type', value: 'value', units: 'units') }
    let(:another_type) { Taxi::Action.new(type: 'another type') }
    let(:another_value) { Taxi::Action.new(type: 'type', value: 'value222') }
    let(:another_distance) { Taxi::Action.new(type: 'type', value: 'value', units: 'units222')}

    it 'compares types and values and distances' do
      expect(subject).to eq(equal_action)
      expect(subject).not_to eq(another_type)
      expect(subject).not_to eq(another_value)
      expect(subject).not_to eq(another_distance)
    end
  end

  describe '#eql?' do
    it 'is aliased as #==' do
      expect(subject.method(:eql?)).to eq(subject.method(:==))
    end
  end

  describe '#cost' do
    its(:cost) { should eq(0) }

    context 'for waiting' do
      subject { Taxi::Action.new(type: :wait) }

      it 'uses a single time unit in calculations' do
        expect(subject.cost(12)).to eq(12)
      end
    end

    context 'for driving' do
      subject { Taxi::Action.new(type: :drive, value: 'destination', units: 2) }

      it 'uses units in calculations' do
        expect(subject.cost(22)).to eq(44)
      end
    end

    context 'for offering' do
      subject { Taxi::Action.new(type: :offer) }
      it 'uses a single time unit in calculations' do
        expect(subject.cost(11)).to eq(11)
      end
    end
  end
end
