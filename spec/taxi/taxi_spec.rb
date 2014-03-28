describe Taxi do
  let(:location) { double(has_passenger?: true) }
  let(:world) { double(reachable_destinations: [1, 2], graph: double(vertices: [location, 1, 2]))}
  let(:min_params) { {world: world, location: location} }
  subject { Taxi.new(min_params) }

  describe 'initialisation' do
    it { should_not be_busy }

    its(:fc) { should eq(1) }
    its(:vc) { should eq(1) }
    its(:prices) {should eq(1..20) }

    it 'sets location' do
      expect(subject.instance_variable_get '@location').to eq(location)
    end

    context 'additional param assignment' do
      subject { Taxi.new(min_params.merge(fc: 22, vc: 33, prices: [1, 2],
                                          learner: 'some learner')) }

      its(:fc) { should eq(22) }
      its(:vc) { should eq(33) }
      its(:prices) {should eq([1, 2]) }

      it 'sets learner' do
        expect(subject.instance_variable_get '@learner').to eq('some learner')
      end

      pending 'refactor this context to bdd'
    end

    context 'instantiates learner correctly' do
      subject { Taxi.new(min_params.merge(prices: [10, 20])) }

      context 'without a passenger at the current location' do
        it 'assigns the minimal actions' do
          location.stub(:has_passenger?) { false }
          expect(Taxi::Learner).to receive(:new) do |args|
            puts args
            expect(args[:available_actions]).to_not be_nil
            expect(args[:available_actions]
              ).to include(Taxi::Action.new(:wait),
                           Taxi::Action.new(:drive, 1),
                           Taxi::Action.new(:drive, 2) )
          end
          subject
        end
      end

      context 'with a passenger at the current location' do
        it 'assigned actions include prices' do
          location.stub(:has_passenger?) { true }
          expect(Taxi::Learner).to receive(:new) do |args|
            expect(args[:available_actions]).to_not be_nil
            expect(args[:available_actions]
              ).to include(Taxi::Action.new(:wait),
                           Taxi::Action.new(:drive, 1),
                           Taxi::Action.new(:drive, 2),
                           Taxi::Action.new(:offer, 10),
                           Taxi::Action.new(:offer, 20) )
          end
          subject
        end
      end

      pending 'states should distinguish passenger destinations'
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