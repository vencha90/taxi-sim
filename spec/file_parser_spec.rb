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
  end

  context 'with a correct input file' do
    subject { TaxiLearner::FileParser.new('spec/fixtures/input.yml') }

    describe '#graph_adjacency_matrix' do
      context 'with incorrect input' do
        it 'raises error on missing top level key' do
          expect{ subject.graph_adjacency_matrix('aaa' => 'aaa') }
            .to raise_error ArgumentError, "no input graph"
        end

        it 'raises error unless a matrix is provided' do
          expect{ subject.graph_adjacency_matrix('graph' => 'a')
            }.to raise_error ArgumentError, 'bad input graph matrix'
        end
      end

      it 'parses graph yaml correctly' do
        yaml = {'graph' => ["0, 1, 2", "1, 2, 3", "2, 3, 4"]}      
        fixture_array = [[0, 1, 2], [1, 2, 3], [2, 3, 4]]
        expect(subject.graph_adjacency_matrix(yaml)).to eq fixture_array
      end

      it 'uses the input file by default' do
        fixture_array = [[0, 1, 2], [1, 0, 2], [2, 2, 0]]
        expect(subject.graph_adjacency_matrix).to eq fixture_array
      end
    end

    describe '#passenger' do
      context 'with incorrect input matrix' do
        it 'raises error on missing top level key' do
          expect{ subject.passenger('aaa' => 'bbb')
            }.to raise_error ArgumentError, 'no input passenger details'
        end

        it 'raises error on missing price per distance' do
          passenger_hash = { 'aaa' => 'bbb' }
          expect{ subject.passenger({'passenger' => passenger_hash})
            }.to raise_error ArgumentError, 'no input passenger expected price'
        end

        it 'raises error on missing more params'
      end

      it 'parses passenger yaml correctly' do
        passenger_hash = { 'price' => '33' }
        expect(subject.passenger({ 'passenger' => passenger_hash })
          ).to eq(price: 33)
      end

      it 'uses the input file by default' do
        expect(subject.passenger).to eq(price: 12)
      end
    end

    describe '#taxi' do
      it 'parses taxi yaml correctly'
    end
  end
end