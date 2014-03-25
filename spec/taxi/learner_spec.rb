describe Taxi::Learner do
  let(:min_params) { {state: 2, environment: [1, 2, 3, 4]} }
  subject { Taxi::Learner.new(min_params)}

  describe 'initialisation' do
    it 'instantiates visited states' do
      expect(subject.visits).to eq([0, 0, 0, 0])
    end

    it 'sets a default discount factor' do
      expect(subject.instance_variable_get '@discount_factor').to eq(0.1)
    end

    it 'sets a default step size function' do
      subject.instance_variable_set('@visits', [0, 2])
      function = subject.instance_variable_get('@step_size_function')
      expect(function.call 1).to eq(0.5)
      expect(function.call 0).to eq(1)
    end

    it 'sets default value estimates' do
      expect(subject.instance_variable_get '@value_estimates'
        ).to eq([0.5, 0.5, 0.5, 0.5])
    end
  end

  describe '#update!' do
    subject { Taxi::Learner.new(state: 0,
      environment: [0, 1, 2],
      discount_factor: 0.2,
      step_size_function: double(call: 0.5),
      value_estimates: [0.3, 0.3, 0.3]
    )}

    let(:update!) { subject.update!(2, 0.5) }

    it 'updates value estimates correctly' do
      expect{ update! 
        }.to change{ subject.value_estimates[0] }.from(0.3)
        .to be_within(0.000001).of(0.43)
    end

    it 'updates visits of old state' do
      expect{ update! }.to change{ subject.visits[0] }.from(0).to(1)
    end

    it 'sets old state to new state' do
      expect{ update! }.to change{ subject.state }.from(0).to(2)
    end
  end

  describe '#act!' do
    it { should respond_to :act! }
    it 'chooses an action'
    it "isn't greedy"
  end
end