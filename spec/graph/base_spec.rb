describe TaxiLearner::Graph::Base do
  subject { TaxiLearner::Graph::Base }

  context 'with invalid input adjacency matrix' do
    it 'raises error on bad empty matrix' do
      expect{ subject.new([])
        }.to raise_error ArgumentError, 'bad matrix dimensions: []'
    end

    it 'raises error on mismatching row lengths' do
      expect{ subject.new([[1],[1,2]])
        }.to raise_error ArgumentError, 'bad matrix dimensions: [[1], [1, 2]]'
    end
  end

  context 'with correct input adjacency matrix' do
    it 'parses adjacency matrix correctly'
  end
end
