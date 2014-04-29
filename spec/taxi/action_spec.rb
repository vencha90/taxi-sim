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

    it 'assigns fixed cost' do
      expect(subject.new(type: nil, fc: 'cost').fc).to eq('cost')
    end

    it 'assigns variable cost' do
      expect(subject.new(type: nil, vc: 'cost').vc).to eq('cost')
    end

  end

  describe '#==' do
    subject { Taxi::Action.new(type: 'type', value: 'value', units: 'units', fc: 'cost', vc: 'vc') }
    let(:equal_action) { Taxi::Action.new(type: 'type', value: 'value', units: 'units', fc: 'cost', vc: 'vc') }
    let(:another_type) { Taxi::Action.new(type: 'another type') }
    let(:another_value) { Taxi::Action.new(type: 'type', value: 'value222') }
    let(:another_distance) { Taxi::Action.new(type: 'type', value: 'value', units: 'units222')}
    let(:another_fc) { Taxi::Action.new(type: 'type', value: 'value', units: 'units', fc: 'cost222')}
    let(:another_vc) { Taxi::Action.new(type: 'type', value: 'value', units: 'units', fc: 'cost', vc: 'other')}

    it 'compares types and values and distances and costs' do
      expect(subject).to eq(equal_action)
      expect(subject).not_to eq(another_type)
      expect(subject).not_to eq(another_value)
      expect(subject).not_to eq(another_distance)
      expect(subject).not_to eq(another_fc)
      expect(subject).not_to eq(another_vc)
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
      subject { Taxi::Action.new(type: :wait, fc: 12, vc: 4) }

      it 'uses a single time unit in calculations' do
        expect(subject.cost).to eq(12)
      end
    end

    context 'for driving' do
      subject { Taxi::Action.new(type: :drive, 
                                 value: 'destination',
                                 units: 2,
                                 fc: 12,
                                 vc: 2) }
      it 'uses units in calculations' do
        expect(subject.cost).to eq(28)
      end
    end

    context 'for offering' do
      subject { Taxi::Action.new(type: :offer, units: 2, fc: 11, vc: 2) }
      it 'uses a single time unit in calculations' do
        expect(subject.cost).to eq(11)
      end

      it 'equals time * distance when accepted (value * unit cost)' do
        expect(subject.cost(accepted: true)).to eq(26)
      end
    end

    it 'cannot be lower than 1' do
      expect(Taxi::Action.new(type: :offer, fc: 0, vc: 0).cost).to eq(1)
    end
  end
end
