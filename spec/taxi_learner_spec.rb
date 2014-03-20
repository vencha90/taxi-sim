describe TaxiLearner::Runner do

  context 'without any params' do
    it 'raises error' do
      expect{ subject }.to raise_error ArgumentError
    end
  end

  context 'with a correct input file' do
    subject { TaxiLearner::Runner.new(['spec/fixtures/input.yml']) }
    let(:fixture_matrix) { fixture_matrix = [[0, 1, 2], [1, 0, 2], [2, 2, 0]] }
    let(:fixture_graph) do
      g = Plexus::UndirectedGraph.new()
      v1 = TaxiLearner::Graph::Vertex.new(1)
      v2 = TaxiLearner::Graph::Vertex.new(2)
      v3 = TaxiLearner::Graph::Vertex.new(3)
      g.add_edge!(v1,v2,1).add_edge!(v1,v3,2).add_edge!(v2,v3,2)
    end

    it 'creates a world' do
      expect(subject.world.graph.graph).to eq(fixture_graph)
    end

    it 'runs a simulation'
    it 'writes a log file'
  end
end