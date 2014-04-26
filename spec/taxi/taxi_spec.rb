describe Taxi do
  let(:world) { double(distance: nil) }
  let(:learner) { double(act!: nil) }
  let(:min_params) { {reachable_destinations: [1, 2],
                      location: 'location',
                      learner: learner,
                      world: world } }
  subject { Taxi.new(min_params) }

  describe 'initialisation' do
    it { should_not be_busy }

    its(:fc) { should eq(1) }
    its(:vc) { should eq(1) }
    its(:prices) { should eq(1..20) }
    its(:reward) { should eq(0) }
    its(:action) { should eq(nil) }
    its(:location) { should eq('location') }
    it { should respond_to :passenger }
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
                                              learner: nil)) }
          it 'is assigned location' do
            expect(Taxi::Learner).to receive(:new) do |args|
              expect(args[:state]).to eq(Taxi::State.new('loc'))
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

  describe '#act' do
    context 'when busy' do
      before { subject.instance_variable_set('@busy_for', 2) }

      it 'decrements time by 1' do
        expect{ subject.act }.to change{ subject.busy_for }.from(2).to(1)
      end

      it 'does not write log' do
        expect(subject).to_not receive(:write_log)
        subject.act
      end

      it 'does not call learner' do
        expect(learner).to_not receive(:act!)
        subject.act
      end
    end

    context 'when no longer busy' do
      before do
        subject.instance_variable_set('@busy_for', 1)
        allow(subject).to receive(:process_action)
          .and_return(reward: 123,
                      location: 'loc',
                      busy_for: 234)
        allow(subject).to receive(:available_actions)
          .and_return('actions')
        allow(subject).to receive(:set_state)
          .and_return('passenger')

        allow(subject).to receive(:write_log)
        allow(subject).to receive(:log_params)
      end

      it 'writes log' do
        expect(subject).to receive(:write_log)
        subject.act
      end

      it 'assigns busy to the new value' do
        expect{ subject.act }.to change{ subject.busy_for }.from(1).to(234)
      end

      it 'changes reward' do
        expect{ subject.act }.to change{ subject.reward }.to(123)
      end

      it 'changes action' do
        allow(learner).to receive(:act!).and_return('action')
        expect{ subject.act }.to change{ subject.action }.to('action')
      end

      it 'changes location' do
        expect{ subject.act }.to change{ subject.location }.to('loc')
      end

      it 'changes passenger' do
        expect{ subject.act('passenger') }.to change{ subject.passenger }.to('passenger')
      end

      it 'uses fixed cost as reward if missing from params' do
        allow(subject).to receive(:process_action).and_return({})
        expect{ subject.act }.to change{ subject.reward }.to(-1)
      end

      context 'calls learner' do
        after { subject.act }
        it 'with the right state' do
          expect(learner).to receive(:act!) do |args|
            expect(args).to include(available_actions: 'actions')
          end
        end

        it 'with the right state' do
          expect(learner).to receive(:act!) do |args|
            expect(args).to include(new_state: 'passenger')
          end
        end

        it 'with the right reward' do
          expect(learner).to receive(:act!) do |args|
            expect(args).to include(reward: 123)
          end
        end
      end
    end
  end

  describe '#process_action' do
    let(:passenger) { double(destination: 'dest', accept_fare?: nil) }
    let(:action) { double(type: nil, value: 32, cost: 23) }
    let(:process_action) { subject
      .process_action(location: 'loc',
                      action: action,
                      passenger: passenger)}
    subject { Taxi.new(min_params.merge(fc: 55))}

    it 'returns default busy_for if no action present' do
      expect(process_action).to eq(busy_for: 1)
    end

    context 'offer' do
      before { allow(action).to receive(:type).and_return(:offer) }
      context 'when passenger accepts fare' do
        before { allow(passenger).to receive(:accept_fare?).and_return(true) }
        it 'returns correct reward (action value - cost)' do
          expect(process_action).to include(reward: 9)
        end

        it "returns passenger's destination as the new location" do
          expect(process_action).to include(location: 'dest')
        end

        it 'returns distance as length of action' do
          allow(world).to receive(:distance).and_return('dist')
          expect(process_action).to include(busy_for: 'dist')
        end

        it 'returns just the right params' do
          expect(process_action.size).to eq(3)
          expect(process_action.keys)
            .to match_array([:busy_for, :location, :reward])
        end
      end

      context 'when passenger declines the fare' do
        before { allow(action).to receive(:accept_fare?).and_return(false) }

        it 'returns correct reward (fixed cost)' do
          expect(process_action).to include(reward: -55)
        end

        it 'returns busy_for == 1' do
          expect(process_action).to include(busy_for: 1)
        end

        it 'returns just the right params' do
          expect(process_action.keys).to match_array([:busy_for, :reward])
          expect(process_action.size).to eq(2)
        end
      end
    end

    context 'when waiting' do
      before { allow(action).to receive(:type).and_return(:wait) }

      it 'returns correct reward (fixed cost)' do
        expect(process_action).to include(reward: -55)
      end

      it 'returns busy_for == 1' do
        expect(process_action).to include(busy_for: 1)
      end

      it 'returns only reward the right params' do
        expect(process_action.keys).to match_array([:busy_for, :reward])
        expect(process_action.size).to eq(2)
      end
    end

    context 'when driving' do
      before do
        allow(action).to receive(:type).and_return(:drive)
        allow(action).to receive(:value).and_return('loc')
        allow(world).to receive(:distance).and_return(123)
      end

      it 'returns correct reward (action cost)' do
        expect(process_action).to include(reward: -23)
      end

      it 'returns location (action value)' do
        expect(process_action).to include(location: 'loc')
      end

      it 'returns busy_for as the distance to cover' do
        expect(process_action).to include(busy_for: 123)
      end

      it 'returns just the right params' do
        expect(process_action.keys)
          .to match_array([:busy_for, :location, :reward])
        expect(process_action.size).to eq(3)
      end

      it 'has no loophole for driving to current location' do
        allow(world).to receive(:distance).and_return(0)
        expect(process_action).to include(busy_for: 1)
      end
    end
  end

  describe '#set_state' do
    context 'when no passenger with a destination' do
      let(:passenger) { double(destination: nil) }

      it 'returns a state with a location only' do
        expect(subject.set_state('location')).to eq(Taxi::State.new('location'))
      end

      it 'returns a state with a destination-less passenger' do
        expect(subject.set_state('location', passenger))
          .to eq(Taxi::State.new('location'))
      end

      it 'does not create duplicates' do
        old_state = subject.set_state('l')
        expect(subject.set_state('l')).to be(old_state)
      end
    end

    context 'with a passenger with a destination' do
      let(:passenger) { double(destination: 'destination') }

      it 'returns a state with a location and a destination' do
        expect(subject.set_state('location', passenger))
          .to eq(Taxi::State.new('location', 'destination'))
      end

      it 'does not create duplicates' do
        old_state = subject.set_state('l', passenger)
        expect(subject.set_state('l', passenger)).to be(old_state)
      end
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

    context 'with a set passenger with a destination' do
      let(:passenger) { double(destination: 'dest') }
      subject { Taxi.new(min_params.merge(
                  reachable_destinations: ['dest'],
                  fc: 11,
                  vc: 22,
                  prices: [10, 20],
                  location: 'loc',
                  world: world )) }
      before { subject.instance_variable_set('@passenger', passenger) }

      it 'returns the right set of actions including offers' do
          expect(subject.available_actions)
            .to include(Taxi::Action.new(type: :wait, unit_cost: 11),
                        Taxi::Action.new(type: :drive, value: 'dest', units: 'dist', unit_cost: 33),
                        Taxi::Action.new(type: :offer, value: 10, unit_cost: 11),
                        Taxi::Action.new(type: :offer, value: 20, unit_cost: 11))
      end

      it 'does not create duplicate actions' do
        older_actions = subject.available_actions
        actions = subject.available_actions
        older_actions.each do |aa|
          actions.each do |action|
            expect(action).to be(aa) if action == aa
          end
        end
      end
    end
  end
end
