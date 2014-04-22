describe World do
  subject { World.new('graph') }

  it 'assigns graph' do
    expect(subject.graph).to eq('graph')
  end

  it 'instantiates time' do
    expect(subject.time).to eq(0)
  end

  describe '#tick' do
    it 'advances internal time' do
      expect{ subject.tick }.to change{ subject.time }.by(1)
    end

    it 'calls actors to act'
    it 'executes actions'
  end

  describe '#reachable_destinations' do
    subject { World.new(double(vertices: 'all vertices')) }

    it 'without args returns all vertices' do
      expect(subject.reachable_destinations).to eq('all vertices')
    end

    it 'with args returns all vertices' do
      expect(subject.reachable_destinations('something')).to eq('all vertices')
    end
  end

  describe '#distance' do
    let(:graph) { double(distance: nil) }
    subject { World.new(graph) }

    it "calls graph's distance function" do
      expect(graph).to receive(:distance).with('a', 'b')
      subject.distance('a', 'b')
    end
  end
end
