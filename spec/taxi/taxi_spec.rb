describe Taxi do
  let(:min_params) { {world: [1, 2, 3, 4], location: 2} }
  subject { Taxi.new(min_params) }

  describe 'initialisation' do
    it { should_not be_busy }

    it 'instantiates a learner' do
      expect(Taxi::Learner).to receive(:new).with(
        state: 2, environment: [1, 2, 3, 4])
      subject
    end

    it 'sets a default fixed cost' do
      expect(subject.instance_variable_get '@fc').to eq(1)
    end

    it 'sets a default variable cost' do
      expect(subject.instance_variable_get '@vc').to eq(1)
    end

    context 'additional param assignment' do
      subject { Taxi.new(min_params.merge(fc: 22, vc: 33,
                                          learner: 'some learner')) }

      it 'sets fixed cost' do
        expect(subject.instance_variable_get '@fc').to eq(22)
      end

      it 'sets variable cost' do
        expect(subject.instance_variable_get '@vc').to eq(33)
      end

      it 'sets learner' do
        expect(subject.instance_variable_get '@learner').to eq('some learner')
      end

      pending 'refactor this context to bdd'
    end
  end

  describe '#act!' do
    let(:learner) { double() }
    subject { Taxi.new(min_params.merge(learner: learner)) }

    it 'calls the internal learner to act' do
      expect(learner).to receive(:act!)
      subject.act!
    end
  end

  describe '#tick!' do
    it { should respond_to :tick! }
    it 'reduces busy time by 1 if busy'
  end
end