describe Graph::Vertex do
  subject { Graph::Vertex.new('some label') }

  describe 'initialisation' do
    it 'sets a label' do
      expect(subject.label).to eq('some label')
    end

    it 'assigns a random probability of having a passenger' do
      expect(0.0..1.0).to cover(subject.passenger_probability)
    end
  end

  describe '#to_s' do
    it 'returns label' do
      expect(subject.to_s).to eq(subject.label)
    end
  end

  describe '#==' do
    let(:equal_vertex) { Graph::Vertex.new('some label') }
    let(:another_vertex) { Graph::Vertex.new('another label') }

    it 'compares labels' do
      expect(subject).not_to eq(another_vertex)
      expect(subject).to eq(equal_vertex)
    end
  end

  describe '#eql?' do
    it 'is aliased as #==' do
      expect(subject.method(:eql?)).to eq(subject.method(:==))
    end
  end

  describe '#hash' do
    it 'hashes the label' do
      expect(subject.hash).to eq(subject.label.hash)
    end
  end

  describe '#has_passenger?' do
    it 'is true if probability large' do
      subject.instance_variable_set('@passenger_probability', 1.1)
      expect(subject.has_passenger?).to be_true
    end

    it 'is false if probability small' do
      subject.instance_variable_set('@passenger_probability', -0.1)
      expect(subject.has_passenger?).to be_false
    end
  end
end
