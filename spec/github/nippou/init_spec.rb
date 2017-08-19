describe Github::Nippou::Init do
  let(:client) { Octokit::Client.new(login: 'taro', access_token: '1234abcd') }
  let(:settings) { double(:settings, user: nil, access_token: nil, gist_id: nil, thread_num: nil,
                          client: nil, create_gist: nil, url: nil, default_url: nil, format: nil, dictionary: nil) }
  let(:init) { described_class.new(settings: settings) }

  it_behaves_like 'a settings interface'
  it_behaves_like 'a init interface'
end
