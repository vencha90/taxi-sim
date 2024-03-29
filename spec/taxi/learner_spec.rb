describe Taxi::Learner do
  let(:state) { 2 }
  let(:available_actions) { ['action'] }
  let(:min_params) { {state: state,
                      available_actions: available_actions} }
  subject { Taxi::Learner.new(min_params)}

  describe 'initialisation' do
    it 'instantiates visited states' do
      expect(subject.visits).to eq( 2 => {} )
    end

    it 'sets a default discount factor' do
      expect(subject.instance_variable_get '@discount_factor').to eq(0.9)
    end

    it 'sets epsilon to use random actions' do
      expect(subject.instance_variable_get '@epsilon').to eq(0.9)
    end

    it 'sets default value estimates for available actions' do
      expect(subject.value_estimates).to eq(2 => {'action' => 0})
    end

    it 'sets a default step size function' do
      subject.instance_variable_set('@visits', {0 => {0 => 0}, 2 => {2 => 2}})
      function = subject.instance_variable_get('@step_size_function')
      expect(function.call 2, 2).to eq(0.5)
      expect(function.call 0, 0).to eq(1)
    end

    context 'parameters' do
      let(:additional_params) { {discount: 0.5,
                                 epsilon: 0.4,
                                 default_value_estimate: 123} }
      subject { Taxi::Learner.new(min_params.merge(params: additional_params))}

      it 'sets a default discount factor' do
        expect(subject.instance_variable_get '@discount_factor').to eq(0.5)
      end

      it 'sets epsilon to use random actions' do
        expect(subject.instance_variable_get '@epsilon').to eq(0.4)
      end

      it 'sets default value estimates for available actions' do
        expect(subject.value_estimates).to eq(2 => {'action' => 123})
      end
    end
  end

  describe '#update!' do
    subject { Taxi::Learner.new(state: 0,
      params: {discount_factor: 0.2},
      step_size_function: double(call: 0.5),
      value_estimates: { 0 => {'action' => 0.5, 'other_action' => 1.0},
                         1 => {'action' => 0.5},
                         2 => {'action' => 0.5} },
      available_actions: ['action']
    )}

    let(:update!) { 
      subject.update!(action: 'action', new_state: 2, reward: 0.5) }

    it 'updates value estimates correctly' do
      expect{ update!
        }.to change{ subject.value_estimates[0]['action'] }.from(0.5)
        .to be_within(0.000001).of(0.725)
    end

    it 'updates visits of old state' do
      expect{ update! 
        }.to change{ subject.visits[0]['action'] }.to(1)
    end

    it 'sets old state to new state' do
      expect{ update! }.to change{ subject.state }.from(0).to(2)
    end

    it 'updates visits of the next state later' do
      expect(subject.visits[2]).to be_nil
      2.times { subject.update!(action: 'action', new_state: 2, reward: 0.5) }
      expect(subject.visits[2]['action']).to eq(1)
      subject.update!(action: 'action', new_state: 2, reward: 0.5)
      expect(subject.visits[2]['action']).to eq(2)      
    end
  end

  describe '#act!' do
    let(:act!) { subject.act!(available_actions: ['action'],
                              new_state: 'new state',
                              reward: 123) }

    it 'sets default value estimates for the next state' do
      allow(subject).to receive(:update!).and_return(nil)
      subject.instance_variable_set('@value_estimates', state => {'a' => 1} )
      expect{ act! 
        }.to change{ subject.value_estimates['new state'] }
         .from(nil)
         .to eq('action' => 0)
    end

    it 'chooses an action' do
      allow(subject).to receive(:update!)
      expect(subject).to receive(:select_action)
      act!
    end

    it 'updates the learner' do
      allow(subject).to receive(:select_action).and_return('selected')
      expect(subject).to receive(:update!)
        .with(action: 'selected', new_state: 'new state', reward: 123)
      act!
    end

    it 'returns the action' do
      allow(subject).to receive(:select_action).and_return('selected')
      allow(subject).to receive(:update!)
      expect(act!).to eq('selected')
    end
  end

  describe '#select_action' do
    context 'exploration strategy' do
      subject { Taxi::Learner.new(min_params.merge(
        value_estimates: { state => {'action' => 10,
                                     'other_action' => 0}} 
      ))}

      let(:select_action) { subject.select_action }

      it 'raises error when no actions available' do
        min_params[:available_actions] = []
        expect{ Taxi::Learner.new(min_params).select_action
          }.to raise_error RuntimeError, "no actions available at this agent's state"
      end

      it 'selects the greedy action with large epsilon' do
        subject.instance_variable_set('@epsilon', 1)
        expect(select_action).to eq('action')
      end

      it 'selects a random action with small epsilon' do
        subject.instance_variable_set('@epsilon', 0)
        expect(['action', 'other_action']).to include(select_action)
      end
    end
  end
end
