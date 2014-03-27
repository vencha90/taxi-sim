describe Taxi::Learner do
  let(:state) { 2 }
  let(:environment) { [1, 2] }
  let(:min_params) { {state: state, environment: environment} }
  subject { Taxi::Learner.new(min_params)}

  describe 'initialisation' do
    it 'instantiates visited states' do
      expect(subject.visits).to eq(1 => {}, 2 => {})
    end

    it 'sets a default discount factor' do
      expect(subject.instance_variable_get '@discount_factor').to eq(0.1)
    end

    it 'sets epsilon to use random actions' do
      expect(subject.instance_variable_get '@epsilon').to eq(0)
    end

    it 'sets a default step size function' do
      subject.instance_variable_set('@visits', [0, 2])
      function = subject.instance_variable_get('@step_size_function')
      expect(function.call 1).to eq(0.5)
      expect(function.call 0).to eq(1)
    end
  end

  describe '#update!' do
    subject { Taxi::Learner.new(state: 0,
      environment: [0, 1, 2],
      discount_factor: 0.2,
      step_size_function: double(call: 0.5),
      value_estimates: { 0 => {'action' => 0.5, 'other_action' => 1.0},
                         1 => {'action' => 0.5},
                         2 => {'action' => 0.5} }
    )}

    let(:update!) { 
      subject.update!(action: 'action', new_state: 2, reward: 0.5) }

    it 'updates value estimates correctly' do
      expect{ update!
        }.to change{ subject.value_estimates[0]['action'] }.from(0.5)
        .to be_within(0.000001).of(0.55)
    end

    it 'updates visits of old state' do
      puts subject.visits
      expect{ update! 
        }.to change{ subject.visits[0]['action'] }.to(1)
    end

    it 'sets old state to new state' do
      expect{ update! }.to change{ subject.state }.from(0).to(2)
    end
  end

  describe '#act!' do
    it 'sets high default value estimates for new actions' do
      expect{ subject.act!(['action']) 
        }.to change{ subject.instance_variable_get('@value_estimates')
        }.from({}).to({ state => {'action' => 100 }})
    end

    it 'chooses an action' do
      expect(subject).to receive(:select_action).with(['action'])
      subject.act!(['action'])
    end

    it 'raises error if no actions available' do
      subject.instance_variable_set('@state', 1)
      subject.instance_variable_set('@value_estimates', { 1 => {'some_action' => 1} })
    end
  end

  describe '#select_action' do
    it 'raises error when no actions available' do
      expect{ subject.select_action([])
        }.to raise_error RuntimeError, "no actions available at this agent's state"
    end

    context 'exploration strategy' do
      subject { Taxi::Learner.new(min_params.merge(
        value_estimates: { state => {'action' => 10,
                                     'other_action' => 0,
                                     'unavailable_action' => 10}} 
      ))}

      let(:select_action) { subject.select_action(['action', 'other_action']) }

      it 'selects the greedy action with large epsilon' do
        subject.instance_variable_set('@epsilon', 1)
        expect(select_action).to eq('action')
      end

      it 'selects a random action with small epsilon' do
        subject.instance_variable_set('@epsilon', 0)
        expect(['action', 'other_action']).to include(select_action)
      end

      it 'never selects the unavailable action' do
        subject.instance_variable_set('@epsilon', 0)
        expect(select_action).to_not eq('unavailable_action')
      end
    end
  end
end
