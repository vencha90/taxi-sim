describe TaxiLearner::Runner do

  context 'without any params' do
    it 'raises error' do
      expect{ subject }.to raise_error ArgumentError
    end
  end

  context 'with a correct input file' do
    subject { TaxiLearner::Runner.new(['spec/fixtures/input.yml']) }

    it 'parses the input file' do
      fixture_array = [[0, 1, 2], [1, 0, 2], [2, 2, 0]]
      expect(subject.yaml).to eq(fixture_array)
      pending 'remove this temp test'
    end

    it 'creates a graph' do
      pending 'using the input'
      expect(subject.graph).to eq(TaxiLearner::Graph::Base.new)
    end

    it 'creates a world' do
      pending 'using the graph'
    end

    it 'runs a simulation'
    it 'writes a log file'
  end
end