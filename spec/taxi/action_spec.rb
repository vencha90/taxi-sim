describe Taxi::Action do
  subject { Taxi::Action.new('type') }
  describe 'initialisation' do
    subject { Taxi::Action }
    it 'assigns type' do
      expect(subject.new('type').type).to eq('type')
    end

    it 'assigns value' do
      expect(subject.new(nil, 'value').value).to eq('value')
    end
  end

  describe '#==' do
    subject { Taxi::Action.new('type', 'value') }
    let(:equal_action) { Taxi::Action.new('type', 'value') }
    let(:another_type) { Taxi::Action.new('another type') }
    let(:another_value) { Taxi::Action.new('type') }

    it 'compares types and values' do
      expect(subject).to eq(equal_action)
      expect(subject).not_to eq(another_type)
      expect(subject).not_to eq(another_value)
    end
  end

  describe '#eql?' do
    it 'is aliased as #==' do
      expect(subject.method(:eql?)).to eq(subject.method(:==))
    end
  end

end