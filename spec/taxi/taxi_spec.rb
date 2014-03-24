describe Taxi do
  describe 'initialisation' do
    it { should_not be_busy }

    context 'assignments' do
      subject { Taxi }
      describe 'fixed cost' do
        it 'is being set' do
          expect(subject.new(fc: 11).fc).to eq(11) 
        end

        it 'defaults to 0' do
          expect(subject.new.fc).to eq(0)
        end
      end
      describe 'variable cost' do
        it 'is being set' do
          expect(subject.new(vc: 22).vc).to eq(22)
        end
        it 'defaults to 0' do
          expect(subject.new.vc).to eq(0)
        end
      end

      describe 'learner' do
        it 'is instantiated' do
          expect(Taxi::Learner).to receive(:new)
          subject.new
        end
      end
    end
  end

  describe '#act!' do
    let(:learner) { double() }
    subject { Taxi.new(learner: learner) }

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