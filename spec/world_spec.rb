describe World do
  let(:vertex) { double(has_passenger?: nil)}
  let(:graph) { double(random_vertex: vertex,
                       vertices: ['all vertices'],
                       distance: nil) }
  let(:passenger_params) { {price: 99} }
  let(:taxi_params) {{ prices: 12..34,
                       benchmark_price: 66,
                       learner_params: 'learner' }}
  subject { World.new(graph: graph, 
                      passenger_params: passenger_params,
                      taxi_params: taxi_params) }

  it 'needs a way to manage all default values'

  describe 'initialisation' do
    it 'assigns graph' do
      expect(subject.graph).to eq(graph)
    end

    it 'instantiates time' do
      expect(subject.time).to eq(0)
    end

    it 'writes log' do
      world = World.allocate
      expect(world).to receive(:write_summary)
      world.__send__(:initialize,
                     graph: graph,
                     passenger_params: passenger_params,
                     taxi_params: taxi_params)
    end
  end

  describe '#run_simulation' do
    let(:taxi) { double(total_profit: 0, location: vertex, act: nil) }
    subject { World.new(graph: graph, 
                        passenger_params: passenger_params,
                        taxi_params: taxi_params,
                        time_limit: 11) }

    before { allow(Taxi).to receive(:new).and_return(taxi) }

    context 'assigns a taxi' do
      it 'without a passenger present' do
        expect(Taxi).to receive(:new)
          .with(world: subject,
                location: vertex,
                reachable_destinations: ['all vertices'],
                prices: 12..34)
        subject.run_simulation
      end

      context 'with a passenger present' do
        before do
          allow(vertex).to receive(:has_passenger?).and_return(true)
          allow(Passenger).to receive(:new)
            .and_return(double(destination: 'destination'))
        end

        it "instantiates a taxi correctly" do
          expect(Taxi).to receive(:new)
            .with(world: subject,
                  location: vertex,
                  reachable_destinations: ['all vertices'],
                  prices: 12..34)
            .and_return(taxi)
          subject.run_simulation
        end
      end
    end

    it 'runs #tick twice, each time until the time runs out' do
      expect(subject).to receive(:tick).exactly(22).times
      subject.run_simulation
    end

    it 'runs #tick again with a benchmark' do
      allow(subject).to receive(:tick)
      expect(Taxi).to receive(:new).with(world: subject,
                location: vertex,
                reachable_destinations: ['all vertices'],
                prices: [66])
      subject.run_simulation
    end

    it 'uses default benchmark prize unless specified' do
      taxi_params.delete(:benchmark_price)
      world = World.new(graph: graph, 
                        passenger_params: passenger_params,
                        taxi_params: taxi_params)
      allow(world).to receive(:tick)
      expect(Taxi).as_null_object.to receive(:new)
        .with(world: world,
              location: vertex,
              reachable_destinations: ['all vertices'],
              prices: [10])
      world.run_simulation
    end

    it 'does not exceed time limit' do
      expect{ subject.run_simulation }.to change{ subject.time 
        }.from(0).to(11)
    end

    it 'writes summary' do
      expect(subject).to receive(:write_summary).twice
      subject.run_simulation
    end
  end

  describe '#tick' do
    let(:taxi) { double(act: nil, :passenger_destination= => nil, location: vertex) }
    let(:passenger) { double(new: nil, destination: nil) }
    
    before do
      subject.instance_variable_set('@taxi', taxi)
      allow(Passenger).to receive(:new).and_return(passenger)
    end

    it 'advances internal time' do
      expect{ subject.tick }.to change{ subject.time }.by(1)
    end

    it 'writes log' do
      expect(subject).to receive(:write_log).with(time: 1)
      subject.tick
    end

    it 'calls taxi to process action' do
      allow(vertex).to receive(:has_passenger?).and_return(true)
      expect(taxi).to receive(:act).with(passenger)
      subject.tick
    end

    context 'sets a new passenger' do
      it 'nil if no passenger present' do
        allow(vertex).to receive(:has_passenger?).and_return(false)
        expect(subject.passenger).to be_nil
        expect{ subject.tick 
          }.to_not change{ subject.passenger }
      end

      context 'if location has a passenger' do
        before { allow(vertex).to receive(:has_passenger?).and_return(true) }
        it 'instantiates passenger with the right params' do
          expect(Passenger).to receive(:new)
            .with({ world: subject, location: vertex}.merge(passenger_params))
          subject.tick
        end

        it 'sets the passenger variable' do
          new_pass = double(destination: nil)
          allow(Passenger).to receive(:new).and_return(new_pass)

          expect{ subject.tick 
            }.to change{ subject.passenger 
            }.from(be_nil).to(new_pass)
        end
      end
    end
  end

  describe '#reachable_destinations' do
    it 'without args returns all vertices' do
      expect(subject.reachable_destinations).to eq(['all vertices'])
    end

    it 'with args returns all vertices' do
      expect(subject.reachable_destinations('something')
        ).to eq(['all vertices'])
    end
  end

  describe '#distance' do
    it "calls graph's distance function" do
      expect(graph).to receive(:distance).with('a', 'b')
      subject.distance('a', 'b')
    end
  end
end
