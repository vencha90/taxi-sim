describe World do
  let(:graph) { double(random_vertex: 'random vx',
                       vertices: ['all vertices'],
                       distance: nil) }
  subject { World.new(graph) }

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
        expect(TaxiLearner::Taxi).to receive(:new).with(
          world: world,
          location: 'random vx',
          reachable_destinations: ['all vertices'])
        world.__send__(:initialize, graph)
      end

      it 'assigns taxi a destination if a passenger is present'
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
