describe TaxiLearner::PassengerCharacteristic do
  subject { TaxiLearner::PassengerCharacteristic }

  describe 'initialisation' do
    it 'sets weight' do
      expect(subject.new(weight: 4).weight).to eq(4)
    end
  end

  describe '#normalised_value' do
    let(:func) { double(call: nil) }

    it 'calculates the value correctly' do
      expect(func).to receive(:call).with('value')
      subject.new(function: func, value: 'value').normalised_value
    end
  end
end
