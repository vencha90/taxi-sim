describe Vertex do
  subject { Vertex.new('some label') }

  describe 'initialisation' do
    it 'sets a label' do
      expect(subject.label).to eq('some label')
    end

    it 'assigns a random probability of having a passenger' do
      expect(0.1..0.9).to cover(subject.passenger_probability)
    end
  end

  describe '#to_s' do
    it 'returns label' do
      expect(subject.to_s).to eq(subject.label)
    end
  end

  describe '==' do
    let(:equal_vertex) { Vertex.new('some label') }
    let(:another_vertex) { Vertex.new('another label') }

    it 'compares labels' do
      expect(subject).not_to eq(another_vertex)
      expect(subject).to eq(equal_vertex)
    end
  end
end