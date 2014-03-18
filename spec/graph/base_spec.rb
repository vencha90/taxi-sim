require 'plexus'

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
    it 'parses adjacency matrix correctly' do
      matrix = [[0, 1, 2], #directed weighted graph
                [1, 0, 1], #the self-loop in final row should be ignored
                [0, 1, 1]]
      graph = Plexus::Digraph.new()
      graph.add_edge!(1,2,1).add_edge!(1,3,2).add_edge!(2,1,1).add_edge!(2,3,1)
        .add_edge!(3,2,1)
      expect(subject.new(matrix).graph
        ).to eq(graph)
    end
  end
end
