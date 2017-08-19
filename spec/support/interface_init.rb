shared_examples_for 'a init interface' do
  subject { init }
  it { is_expected.to respond_to :run }
end
