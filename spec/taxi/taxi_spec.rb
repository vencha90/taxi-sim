describe Taxi do
  let(:min_params) { {reachable_destinations: [1, 2],
                      location: 'location',
                      learner: double(act!: nil)} }
  subject { Taxi.new(min_params) }

  describe 'initialisation' do
    it { should_not be_busy }

    its(:fc) { should eq(1) }
    its(:vc) { should eq(1) }
    its(:prices) {should eq(1..20) }

    context 'additional param assignment' do
      subject { Taxi.new(min_params.merge(fc: 22, vc: 33,
                                          learner: 'some learner')) }

      its(:fc) { should eq(22) }
      its(:vc) { should eq(33) }

      it 'sets learner' do
        expect(subject.instance_variable_get '@learner').to eq('some learner')
      end
    end

    context 'instantiates learner' do
      context 'assigned actions' do
        context 'without a set destination' do
          subject { Taxi.new(min_params.merge(learner: nil)) }
          it 'include the minimal set of actions' do
            expect(Taxi::Learner).to receive(:new) do |args|
              expect(args[:available_actions]
                ).to include(Taxi::Action.new(:wait),
                             Taxi::Action.new(:drive, 1),
                             Taxi::Action.new(:drive, 2) )
            end
            subject
          end
        end

        context 'with a set destination' do
          subject { Taxi.new(min_params.merge(prices: [10, 20],
                                              passenger_destination: 'dest',
                                              reachable_destinations: ['a'],
                                              learner: nil)) }
          it 'include prices' do
            expect(Taxi::Learner).to receive(:new) do |args|
              expect(args[:available_actions]
                ).to include(Taxi::Action.new(:wait),
                             Taxi::Action.new(:drive, 'a'),
                             Taxi::Action.new(:offer, 10),
                             Taxi::Action.new(:offer, 20))
            end
            subject
          end
        end
      end

      context 'state' do
        context 'with a destination present' do
          subject { Taxi.new(min_params.merge(location: 'loc',
                                              passenger_destination: 'dest',
                                              learner: nil)) }
          it 'is assigned location and destination' do
            expect(Taxi::Learner).to receive(:new) do |args|
              expect(args[:state]).to eq(Taxi::State.new('loc', 'dest'))
            end
            subject
          end
        end

        context 'with no destination present' do
          subject { Taxi.new(min_params.merge(location: 'loc', learner: nil)) }

          it 'is only assigned a location' do
            expect(Taxi::Learner).to receive(:new) do |args|
              expect(args[:state]).to eq(Taxi::State.new('loc'))
            end
            subject
          end
        end
      end
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
    it 'reduces busy time by 1 if busy' do
      subject.instance_variable_set('@busy_for', 1)
      expect{ subject.tick! }.to change{ subject.busy? }.from(be_true).to(be_false)
    end

    it 'calls #act!' do
      expect(subject).to receive(:act!)
      subject.tick!
    end
  end
end