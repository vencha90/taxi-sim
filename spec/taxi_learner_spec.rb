describe TaxiLearner do

  describe 'input parsing' do
    subject { TaxiLearner }
    context 'fails' do
      it 'without any params' do
        expect{ subject.new }.to raise_error
      end

      it 'with an invalid file path' do
        ARGV[0] = 'no/file/here'
        expect{ subject.new(ARGV) }.to raise_error
      end
    end

    context 'succeeds' do
      it 'with a correct filename' do
        pending
        ARGV[0] = 'spec/fixtures/input.yml'
        expect(subject.new(ARGV).file).to eq('something')
      end
    end
  end
end