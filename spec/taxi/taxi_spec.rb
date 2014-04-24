describe Taxi do
  let(:min_params) { {reachable_destinations: [1, 2],
                      location: 'location',
                      learner: double(act!: nil),
                      world: double(distance: nil)} }
  subject { Taxi.new(min_params) }

  describe 'initialisation' do
    it { should_not be_busy }

    its(:fc) { should eq(1) }
    its(:vc) { should eq(1) }
    its(:prices) { should eq(1..20) }
    its(:reward) { should eq(0) }
    its(:action) { should eq(nil) }
    its(:location) { should eq('location') }
    it { should respond_to :passenger_destination= }
    it { should respond_to :passenger_destination }
    it { should respond_to :busy_for= }
    it { should respond_to :busy_for }

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
      subject { Taxi.new(min_params.merge(learner: nil)) }
      it 'includes available actions' do
        allow_any_instance_of(Taxi
          ).to receive(:available_actions
          ).and_return([1, 2, 3])
        expect(Taxi::Learner).to receive(:new) do |args|
          expect(args[:available_actions]).to include(1, 2, 3)
        end
        subject
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
                      # reachable_destinations: [1],
                      # passenger_destination: 'dest',
                      # prices: [10],
                      location: 'loc',
                      # reward: 10,
                      world: double(distance: nil))) }

    it 'keeps track of the last action' do
      allow(learner).to receive(:act!).and_return('action')
      expect{ subject.act! 
        }.to change{ subject.instance_variable_get('@action')
        }.from(nil).to('action')
    end

    context 'calls the internal learner' do
      it 'with the available actions' do
        allow(subject).to receive(:available_actions).and_return([1, 2, 3])
        expect(learner).to receive(:act!) do |args|
          expect(args[:available_actions]).to include(1, 2, 3)
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
        subject.instance_variable_set('@action', double(cost: 30))
        expect(learner).to receive(:act!) do |args|
          expect(args[:reward]).to eq(50)
        end
        subject.act!
      end
    end
  end

  describe '#tick!' do
    it 'reduces busy time by 1 if busy' do
      subject.busy_for = 1
      expect{ subject.tick! 
        }.to change{ subject.busy? }.from(be_true).to(be_false)
    end

    it 'sets the new reward' do
      expect{ subject.tick!(reward: 20)
        }.to change{ subject.instance_variable_get('@reward')
        }.from(0).to(20)
    end

    it 'sets the new location' do
      expect{ subject.tick!(reward: 0, location: 'loc')
        }.to change{ subject.location }.to('loc')
    end

    it 'calls #act!' do
      expect(subject).to receive(:act!)
      subject.tick!
    end
  end

  describe '#available_actions' do
    let(:world) { double(distance: 'dist') }

    context 'without a set destination' do
      subject { Taxi.new(min_params.merge(
                  reachable_destinations: ['dest'],
                  fc: 11,
                  vc: 22,
                  prices: [10],
                  location: 'loc',
                  world: world)) }

      it 'returns the right set of actions - only driving and waiting' do
        expect(subject.available_actions
          ).to include(
            Taxi::Action.new(type: :wait, unit_cost: 11),
            Taxi::Action.new(type: :drive, value: 'dest', units: 'dist', unit_cost: 33),
          )
      end
    end

    context 'with a set destination' do
      subject { Taxi.new(min_params.merge(
                  reachable_destinations: ['dest'],
                  passenger_destination: 'any',
                  fc: 11,
                  vc: 22,
                  prices: [10, 20],
                  location: 'loc',
                  world: world )) }
      it 'returns the right set of actions including offers' do
          expect(subject.available_actions
            ).to include(Taxi::Action.new(type: :wait, unit_cost: 11),
                         Taxi::Action.new(type: :drive, value: 'dest', units: 'dist', unit_cost: 33),
                         Taxi::Action.new(type: :offer, value: 10, unit_cost: 11),
                         Taxi::Action.new(type: :offer, value: 20, unit_cost: 11))
      end
    end
  end
end
