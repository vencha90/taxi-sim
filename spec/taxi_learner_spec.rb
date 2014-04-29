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
        allow(params).to receive(:time_limit).and_return(nil)
        expect(FileParser).to receive(:new).with(file_path).and_return(params)
        expect(Graph).to receive(:new).with(['matrix']).and_return('graph')
        expect(World).to receive(:new)
          .with(graph: 'graph',
                passenger_params: 'passenger',
                taxi_params: 'taxi')
          .and_return(double(run_simulation: nil))
        subject
      end

      it 'passes time limit if included' do
        allow(params).to receive(:time_limit).and_return(100)
        allow(FileParser).to receive(:new).and_return(params)
        allow(Graph).to receive(:new).and_return('graph')
        expect(World).to receive(:new)
          .with(graph: 'graph',
                passenger_params: 'passenger',
                taxi_params: 'taxi',
                time_limit: 100)
          .and_return(double(run_simulation: nil))
        subject
      end
    end
  end
end
