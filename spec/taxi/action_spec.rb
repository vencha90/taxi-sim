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

    it 'assigns unit cost' do
      expect(subject.new(type: nil, unit_cost: 'cost').unit_cost).to eq('cost')
    end
  end

  describe '#==' do
    subject { Taxi::Action.new(type: 'type', value: 'value', units: 'units', unit_cost: 'cost') }
    let(:equal_action) { Taxi::Action.new(type: 'type', value: 'value', units: 'units', unit_cost: 'cost') }
    let(:another_type) { Taxi::Action.new(type: 'another type') }
    let(:another_value) { Taxi::Action.new(type: 'type', value: 'value222') }
    let(:another_distance) { Taxi::Action.new(type: 'type', value: 'value', units: 'units222')}
    let(:another_cost) { Taxi::Action.new(type: 'type', value: 'value', units: 'units', unit_cost: 'cost222')}

    it 'compares types and values and distances' do
      expect(subject).to eq(equal_action)
      expect(subject).not_to eq(another_type)
      expect(subject).not_to eq(another_value)
      expect(subject).not_to eq(another_distance)
      expect(subject).not_to eq(another_cost)
    end
  end

  describe '#eql?' do
    it 'is aliased as #==' do
      expect(subject.method(:eql?)).to eq(subject.method(:==))
    end
  end

  describe '#cost' do
    its(:cost) { should eq(1) }

    context 'for waiting' do
      subject { Taxi::Action.new(type: :wait, unit_cost: 12) }

      it 'uses a single time unit in calculations' do
        expect(subject.cost).to eq(12)
      end
    end

    context 'for driving' do
      subject { Taxi::Action.new(type: :drive, 
                                 value: 'destination',
                                 units: 2,
                                 unit_cost: 12) }
      it 'uses units in calculations' do
        expect(subject.cost).to eq(24)
      end
    end

    context 'for offering' do
      subject { Taxi::Action.new(type: :offer, units: 2, unit_cost: 11) }
      it 'uses a single time unit in calculations' do
        expect(subject.cost).to eq(11)
      end

      it 'equals time * distance when accepted (value * unit cost)' do
        expect(subject.cost(accepted: true)).to eq(22)
      end
    end

    it 'cannot be lower than 1' do
      expect(Taxi::Action.new(type: :offer, unit_cost: 0).cost).to eq(1)
    end
  end
end
