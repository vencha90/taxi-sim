describe World do
  let(:vertex) { double(has_passenger?: nil)}
  let(:graph) { double(random_vertex: vertex,
                       vertices: ['all vertices'],
                       distance: nil) }
  subject { World.new(graph: graph) }

  describe 'initialisation' do
    it 'assigns graph' do
      expect(subject.graph).to eq(graph)
    end

    it 'instantiates time' do
      expect(subject.time).to eq(0)
    end

    context 'assigns a taxi' do
      subject(:world) { World.allocate }

      it 'without a passenger present' do
        expect(Taxi).to receive(:new)
          .with(world: world,
                location: vertex,
                reachable_destinations: ['all vertices'])
        world.__send__(:initialize, graph: graph)
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
                  price: 2)
          world.__send__(:initialize, graph: graph, expected_price: 2)
        end

        it "assigns passenger's destination to a taxi" do
          expect(Taxi).to receive(:new)
            .with(world: world,
                  location: vertex,
                  reachable_destinations: ['all vertices'],
                  passenger_destination: 'destination')
          world.__send__(:initialize, graph: graph, expected_price: 2)
        end
      end
    end
  end

  describe '#tick' do
    it 'advances internal time' do
      expect{ subject.tick }.to change{ subject.time }.by(1)
    end

    it 'calls actors to act'
    it 'executes actions'
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
