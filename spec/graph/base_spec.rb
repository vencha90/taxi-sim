require 'plexus'

describe TaxiLearner::Graph::Base do
  subject { TaxiLearner::Graph::Base }

  describe 'initialisation' do
    it 'raises error on bad empty matrix' do
      expect{ subject.new([])
        }.to raise_error ArgumentError, 'bad matrix dimensions: []'
    end

    it 'raises error on mismatching row lengths' do
      expect{ subject.new([[1],[1,2]])
        }.to raise_error ArgumentError, 'bad matrix dimensions: [[1], [1, 2]]'
    end

    it 'ignores self loops' do
      internal_graph = Plexus::Digraph.new
      internal_graph.add_edge!(1,2,1).add_edge!(2,1,1)
      expect(subject.new([[1,1],[1,1]]).graph).to eq(internal_graph)
    end
  end

  context 'with correct input adjacency matrix' do
    let(:internal_graph) { Plexus::Digraph.new() }
    let(:matrix) { [[0, 1, 2], #directed weighted graph
                    [1, 0, 1],
                    [0, 3, 1]] }
    subject { TaxiLearner::Graph::Base.new(matrix) }

    before do
      internal_graph.add_edge!(1,2,1)
                    .add_edge!(1,3,2)
                    .add_edge!(2,1,1)
                    .add_edge!(2,3,1)
                    .add_edge!(3,2,3)
     end

    it 'initialises correctly' do
      expect(subject.graph).to eq(internal_graph)
    end

    describe '#path_weight' do      
      it 'returns a weight for the shortest path' do
        expect(subject.path_weight(1,2)).to eq(1)
        expect(subject.path_weight(1,3)).to eq(2)
        expect(subject.path_weight(3,1)).to eq(4)
      end
    end
  end
end
