describe Runner do

  describe 'initialisation' do
    context 'without any params' do
      it 'raises error' do
        expect{ subject }.to raise_error ArgumentError
      end
    end

    context 'with an input file' do
      let(:file_path) { 'spec/fixtures/input.yml' }
      let(:params) { double(graph_adjacency_matrix: ['matrix'],
                            passenger: 'passenger',
                            taxi: 'taxi') }
      subject { Runner.new([file_path]) }
      
      it 'creates a world with params from file' do
        expect(FileParser).to receive(:new).with(file_path).and_return(params)
        expect(Graph).to receive(:new).with(['matrix']).and_return('graph')
        expect(World).to receive(:new)
          .with(graph: 'graph',
                passenger_params: 'passenger',
                taxi_params: 'taxi')
        subject
      end
    end
  end

  it 'runs a simulation'
  it 'writes a log file'
end
