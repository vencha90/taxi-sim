describe TaxiLearner::FileParser do
  context 'fails' do
    subject { TaxiLearner::FileParser }

    context 'with no args' do
      it 'raises argument error' do
        expect{ subject.new }.to raise_error ArgumentError
      end
    end
    context 'with an incorrect filename' do
      it 'raises error' do
        expect{ subject.new('/no/file/here') }.to raise_error Errno::ENOENT
      end
    end
    context 'with a bad input file' do
      subject { TaxiLearner::FileParser.new('spec/fixtures/bad_input.yml') }
      
      it 'checks the required variables' do
        expect{ subject }
          .to raise_error ArgumentError, "'graph' not found in input file"
      end
    end
  end

  context 'with a correct input file' do
    subject { TaxiLearner::FileParser.new('spec/fixtures/input.yml') }

    describe '#graph_adjacency_matrix' do
      it 'parses yaml correctly' do
        fixture_array = [[0, 1, 2], [1, 0, 2], [2, 2, 0]]
        expect(subject.graph_adjacency_matrix).to eq fixture_array
      end
    end
  end

  describe '.graph_adjacency_matrix' do
    subject { TaxiLearner::FileParser }

    context 'with incorrect input matrix' do
      it 'raises error' do
        expect{ subject.graph_adjacency_matrix('graph' => 'a')
          }.to raise_error ArgumentError, 'bad input graph matrix'
      end
    end
  end
end