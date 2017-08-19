shared_examples_for 'a settings interface' do
  subject { settings }
  it { is_expected.to respond_to :gist_id }
  it { is_expected.to respond_to :create_gist }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :format }
  it { is_expected.to respond_to :dictionary }
end
