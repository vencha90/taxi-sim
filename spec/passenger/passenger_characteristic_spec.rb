describe Passenger::Characteristic do
  subject { Passenger::Characteristic }

  describe 'initialisation' do
    it 'assigns weight' do
      expect(subject.new(weight: 4).weight).to eq(4)
    end

    it 'assigns a default weight' do
      expect(subject.new.weight).to eq(1)
    end
  end

  describe '#normalised_value' do
    let(:func) { double(call: nil) }

    it 'calculates the value correctly with input function' do
      expect(func).to receive(:call).with('value')
      subject.new(function: func, value: 'value').normalised_value
    end

    it 'has a default function' do
      expect(subject.new(value: 2).normalised_value).to eq(0.5)
    end

    it 'has a default function and value' do
      expect(subject.new.normalised_value).to eq(0.25)
    end
  end
end
