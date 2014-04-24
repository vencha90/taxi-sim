describe World do
  let(:vertex) { double(has_passenger?: nil)}
  let(:graph) { double(random_vertex: vertex,
                       vertices: ['all vertices'],
                       distance: nil) }
  let(:passenger_params) { {price: 99} }
  let(:taxi_params) {{ prices: 12..34,
                       benchmark_price: 66 }}
  subject { World.new(graph: graph, 
                      passenger_params: passenger_params,
                      taxi_params: taxi_params) }

  it 'assigns taxi params to new taxis: with fixed price and a range of prices'

  describe 'initialisation' do
    it 'assigns graph' do
      expect(subject.graph).to eq(graph)
    end

    it 'instantiates time' do
      expect(subject.time).to eq(0)
    end

    context 'assigns a taxi' do
      subject(:world) { World.allocate }
      let(:initialise_world) do
         world.__send__(:initialize, 
                        graph: graph,
                        passenger_params: passenger_params,
                        taxi_params: taxi_params)
      end

      it 'without a passenger present' do
        expect(Taxi).to receive(:new)
          .with(world: world,
                location: vertex,
                reachable_destinations: ['all vertices'])
        initialise_world
      end

      context 'with a passenger present' do
        before do
          allow(vertex).to receive(:has_passenger?).and_return(true)
          allow(Passenger).to receive(:new)
            .and_return(double(destination: 'destination'))
        end

        it 'instantiates a passenger correctly' do
          expect(Passenger).to receive(:new)
            .with(world: world,
                  location: vertex,
                  price: 99)
          initialise_world
        end

        it "instantiates a taxi correctly" do
          expect(Taxi).to receive(:new)
            .with(world: world,
                  location: vertex,
                  reachable_destinations: ['all vertices'])
            .and_call_original
          initialise_world
        end

        it "assigns passenger's destination" do
          initialise_world
          expect(world.instance_variable_get('@taxi').passenger_destination)
            .to eq('destination')
        end
      end
    end
  end

  describe '#tick' do
    let(:taxi) { subject.instance_variable_get('@taxi') }
    let(:action) { double(type: nil, cost: 5) }
    let(:passenger) { double(destination: vertex) }
    before { subject.instance_variable_set('@passenger', passenger) }

    it 'needs a refactor'

    it 'advances internal time' do
      expect{ subject.tick }.to change{ subject.time }.by(1)
    end

    context 'with a selected action' do
      before do
        allow(taxi).to receive(:action).and_return(action)
        allow(action).to receive(:value).and_return(0)
      end

      it 'assigns taxi as busy' do
        expect{ subject.tick
          }.to change{ taxi.busy? }.from(be_false).to(be_true)
      end

      it "sets taxi busy for as long as the action costs" do
        expect{ subject.tick
          }.to change{ taxi.busy_for }.from(0).to(5)
      end

      context 'when offer is accepted by passenger' do
        before do
          allow(passenger).to receive(:accept_fare?).and_return(true)
          allow(passenger).to receive(:destination).and_return(vertex)
          allow(action).to receive(:type).and_return(:offer)
        end

        it 'does not assign a new passenger' do
          expect{ subject.tick }.to_not change{ passenger }
        end

        it "does not change taxi's destination" do
          expect{ subject.tick }.to_not change{ taxi.passenger_destination }
        end

        context 'if the new location has a passenger' do
          before { allow(vertex).to receive(:has_passenger?).and_return(true) }

          it 'assigns a new passenger' do
            expect(Passenger).to receive(:new)
              .with(world: subject,
                    location: vertex,
                    price: 99)
              .and_call_original
            subject.tick
          end

          it "changes taxi's destination to the new passenger's" do
            allow(Passenger).to receive(:new)
              .and_return(double(destination: 'dest'))
            expect{ subject.tick
              }.to change{ taxi.passenger_destination }.to('dest')
          end
        end
      end

      context 'rewards only cost' do
        it 'when action is not an offer' do
          expect(taxi).to receive(:tick!).with(reward: -5)
          subject.tick
        end

        it 'when action is an offer but passenger declines fare' do
          allow(action).to receive(:type).and_return(:offer)
          allow(passenger).to receive(:accept_fare?).and_return(false)
          expect(taxi).to receive(:tick!).with(reward: -5)
          subject.tick
        end
      end
    end

    context 'when no action selected' do
      it 'calls taxi#tick!' do
        expect(taxi).to receive(:tick!).with(no_args)
        subject.tick
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
