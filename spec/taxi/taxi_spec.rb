describe Taxi do
  let(:min_params) { {reachable_destinations: [1, 2],
                      location: 'location',
                      learner: double(act!: nil)} }
  subject { Taxi.new(min_params) }

  describe 'initialisation' do
    it { should_not be_busy }

    its(:fc) { should eq(1) }
    its(:vc) { should eq(1) }
    its(:prices) { should eq(1..20) }
    its(:reward) { should eq(0) }
    its(:action) { should eq(nil) }
    it { should respond_to :passenger_destination= }
    it { should respond_to :passenger_destination }

    context 'additional param assignment' do
      subject { Taxi.new(min_params.merge(fc: 22, vc: 33,
                                          learner: 'some learner',
                                          reward: 123)) }

      its(:fc) { should eq(22) }
      its(:vc) { should eq(33) }
      its(:reward) { should eq(123) }

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
    let(:learner) { double(act!: nil) }
    subject { Taxi.new(min_params.merge(learner: learner,
                      reachable_destinations: [1],
                      passenger_destination: 'dest',
                      prices: [10],
                      location: 'loc',
                      reward: 10)) }

    it 'keeps track of the last action' do
      learner.stub(:act!).and_return('action')
      expect{ subject.act! 
        }.to change{ subject.instance_variable_get('@action')
        }.from(nil).to('action')
    end

    context 'calls the internal learner' do
      it 'with the available actions' do
        expect(learner).to receive(:act!) do |args|
          expect(args[:available_actions]
            ).to include(
              Taxi::Action.new(:wait),
              Taxi::Action.new(:drive, 1),
              Taxi::Action.new(:offer, 10)
            )
          end
        subject.act!
      end

      it 'with the new state' do
        expect(learner).to receive(:act!) do |args|
          expect(args[:new_state]).to eq(subject.instance_variable_get '@state')
        end
        subject.act!
      end

      it 'with the new reward' do
        subject.instance_variable_set('@reward', 20)
        subject.stub(get_action_profit: 20)      
        expect(learner).to receive(:act!) do |args|
          expect(args[:reward]).to eq(40)
        end
        subject.act!
      end
    end
  end

  describe '#tick!' do
    it 'reduces busy time by 1 if busy' do
      subject.instance_variable_set('@busy_for', 1)
      expect{ subject.tick! 
        }.to change{ subject.busy? }.from(be_true).to(be_false)
    end

    it 'sets the new reward' do
      expect{ subject.tick!(reward: 20)
        }.to change{ subject.instance_variable_get('@reward')
        }.from(0).to(20)
    end

    it 'calls #act!' do
      expect(subject).to receive(:act!)
      subject.tick!
    end
  end

  describe '#get_action_profit' do
    it 'calculates profit for waiting'
    it 'calculates profit for driving empty'
    it 'calculates profit for serving a passenger'
  end
end