describe FileParser do
  context 'fails' do
    subject { FileParser }

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
    subject { FileParser.new('spec/fixtures/input.yml') }

    describe '#graph_adjacency_matrix' do
      context 'with incorrect input' do
        it 'raises error on missing top level key' do
          expect{ subject.graph_adjacency_matrix('aaa' => 'aaa') 
            }.to raise_error ArgumentError, "no input graph"
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
        expect(subject.passenger({ 'passenger' => passenger_hash }))
          .to eq(price: 33)
      end

      it 'uses the input file by default' do
        expect(subject.passenger).to eq(price: 12)
      end
    end

    describe '#taxi' do
      context 'with incorrect input' do
        it 'raises error on missing top level key' do
          expect{ subject.taxi('aaa' => 'bbb') 
            }.to raise_error ArgumentError, 'no input taxi details'
        end
      end

      it 'uses the input file by default' do
        expect(subject.taxi).to eq(prices: 12..34, benchmark_price: 123)
      end

      context 'price range' do
        it 'raises error on invalid input' do
          expect{ subject.taxi('taxi' => { 'prices' => 'aa'} )
            }.to raise_error ArgumentError, 'bad price range entered for taxi'
        end

        it 'parses single number correctly' do
          expect( subject.taxi('taxi' => { 'prices' => '33'}))
            .to eq(prices: [33])
        end

        it 'parses range correctly' do
          expect( subject.taxi('taxi' => { 'prices' => '33..44'}))
            .to eq(prices: 33..44)
        end

        it 'is excluded from params when empty' do
          expect(subject.taxi('taxi' => {})).to_not have_key(:prices)
        end
      end

      context 'benchmark price' do
        it 'is parsed correctly' do
          expect(subject.taxi('taxi' => { 'benchmark_price' => '12'}))
            .to eq(benchmark_price: 12)
        end

        it 'raises error on non-numeric values' do
          expect{ subject.taxi('taxi' => { 'benchmark_price' => 'a'}) 
            }.to raise_error ArgumentError, 'bad benchmark price entered for taxi'
        end

        it 'is excluded from params when empty' do
          expect(subject.taxi('taxi' => {})).to_not have_key(:benchamark_price)
        end
      end
    end
  end
end
