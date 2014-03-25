describe Graph do
  subject { Graph.new([[0, 1, 2],
                      [0, 0, 1],
                      [0, 0, 0]]) }
  let(:v1) { Graph::Vertex.new(1) }
  let(:v2) { Graph::Vertex.new(2) }
  let(:v3) { Graph::Vertex.new(3) }


  describe 'initialisation' do
    subject { Graph }
    let(:internal_graph) { Plexus::UndirectedGraph.new() }

    it 'raises error on bad empty matrix' do
      expect{ subject.new([])
        }.to raise_error ArgumentError, 'bad matrix dimensions: []'
    end

    it 'raises error on mismatching row lengths' do
      expect{ subject.new([[1],[1,2]])
        }.to raise_error ArgumentError, 'bad matrix dimensions: [[1], [1, 2]]'
    end

    it 'raises error if graph is not connected' do
      pending 'not implemented in plexus'
      expect{ subject.new([[0,1,0,0],
                           [1,0,0,0],
                           [0,0,0,1],
                           [0,0,1,0]]) 
        }.to raise_error ArgumentError, 'input matrix graph is not connected'
    end

    it 'ignores self loops' do
      expect(subject.new([[1,0],[0,0]]).graph).to eq(internal_graph)
    end

    it 'does not add duplicate edges' do
      internal_graph.add_edge!(v1,v2,1)
      expect(subject.new([[0,1],[1,0]]).graph).to eq(internal_graph)
    end

    context 'with a correct input adjacency matrix' do
      it 'initialises correctly' do
        matrix = [[0, 0, 0],
                  [1, 0, 1],
                  [2, 0, 0]]
        internal_graph.add_edge!(v1,v2,1)
                      .add_edge!(v1,v3,2)
                      .add_edge!(v2,v3,1)
        expect(subject.new(matrix).graph).to eq(internal_graph)
      end
    end
  end

  describe '#find_vertex_by_label' do
    it 'returns the right vertex' do
      v1 = subject.graph.vertices.sort.first
      v3 = subject.graph.vertices.sort.last
      expect(subject.find_vertex_by_label(1)).to eq(v1)
      expect(subject.find_vertex_by_label(3)).to eq(v3)
    end

    it 'returns nil if not found' do
      expect(subject.find_vertex_by_label('none')).to be_nil
    end
  end

  describe '#path_weight' do
    it 'is aliased as #distance' do
      expect(subject.method(:path_weight)).to eq(subject.method(:distance))
    end

    it 'returns a weight for the shortest path' do
      expect(subject.path_weight(1,2)).to eq(1)
      expect(subject.path_weight(1,3)).to eq(2)
      expect(subject.path_weight(3,1)).to eq(2)
    end
  end

  describe '#random_vertex' do
    it 'returns a randomly chosen vertex' do
      expect(subject.graph.vertices).to include(subject.random_vertex)
    end
  end
end
