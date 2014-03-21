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
end
