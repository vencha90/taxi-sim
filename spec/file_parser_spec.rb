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
      it 'checks that graph is included' do
        expect{ subject.new('spec/fixtures/bad_input.yml') }
          .to raise_error ArgumentError, "'graph' not found in input file"
      end
    end
  end

  context 'with a correct input file' do
    subject { TaxiLearner::FileParser.new('spec/fixtures/input.yml') }

    describe '#graph_adjacency_matrix' do
      context 'with incorrect input matrix' do
        it 'raises error' do
          expect{ subject.graph_adjacency_matrix('graph' => 'a')
            }.to raise_error ArgumentError, 'bad input graph matrix'
        end
      end

      it 'parses graph yaml correctly' do
        yaml = {'graph' => ["0, 1, 2", "1, 2, 3", "2, 3, 4"]}      
        fixture_array = [[0, 1, 2], [1, 2, 3], [2, 3, 4]]
        expect(subject.graph_adjacency_matrix(yaml)).to eq fixture_array
      end

      it 'uses the file by default' do
        fixture_array = [[0, 1, 2], [1, 0, 2], [2, 2, 0]]
        expect(subject.graph_adjacency_matrix).to eq fixture_array
      end
    end

    describe '#passenger' do
      it 'parses passenger yaml correctly'
    end

    describe '#taxi' do
      it 'parses taxi yaml correctly'
    end
  end
end