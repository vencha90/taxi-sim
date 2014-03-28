describe Taxi::State do
  subject { Taxi::State.new('location') }
  describe 'initialisation' do
    subject { Taxi::State }
    it 'assigns location' do
      expect(subject.new('location').location).to eq('location')
    end

    it 'assigns destination' do
      expect(subject.new('loc', 'dest').destination).to eq('dest')
    end
  end

  describe '#==' do
    subject { Taxi::State.new('location', 'destination') }
    let(:equal) { Taxi::State.new('location', 'destination') }
    let(:same_location) { Taxi::State.new('location') }
    let(:same_destination) { Taxi::State.new('loc', 'destination') }

    it 'compares location and destination' do
      expect(subject).to eq(equal)
      expect(subject).not_to eq(same_location)
      expect(subject).not_to eq(same_destination)
    end
  end

  describe '#eql?' do
    it 'is aliased as #==' do
      expect(subject.method(:eql?)).to eq(subject.method(:==))
    end
  end
end
