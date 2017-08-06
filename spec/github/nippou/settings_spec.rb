describe Github::Nippou::Settings do
  let(:client) { Octokit::Client.new(login: 'taro', access_token: '1234abcd') }
  let(:settings) { described_class.new(client: client) }

  after { ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = nil }

  describe '#gist_id' do
    before { ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = '0123456789' }

    it 'is valid' do
      expect(settings.gist_id).to eq '0123456789'
    end
  end

  describe '#create_gist' do
    it 'responds to #create_gist' do
      expect(client).to respond_to :create_gist
    end
  end

  describe '#format' do
    before do
      ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = '12345'
      allow(client).to receive(:gist).and_return( files: { 'settings.yml': { content: settings_yaml } } )
    end

    context 'given valid settings' do
      let(:settings_yaml) { load_fixture('settings-valid.yml') }

      it 'is valid `subject`' do
        expect(settings.format.subject).to eq '### %{subject}'
      end

      it 'is valid `line`' do
        expect(settings.format.line).to eq '* [%{title}](%{url}) by %{user} %{status}'
      end
    end

    context 'given invalid settings' do
      let(:settings_yaml) { load_fixture('settings-invalid.yml') }

      it 'outputs YAML syntax error message' do
        expect { settings.format }.to raise_error Psych::SyntaxError
      end
    end
  end

  describe '#dictionary' do
    before do
      ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = '12345'
      allow(client).to receive(:gist).and_return( files: { 'settings.yml': { content: settings_yaml } } )
    end

    context 'given valid settings' do
      let(:settings_yaml) { load_fixture('settings-valid.yml') }

      it 'is valid `status.merged`' do
        expect(settings.dictionary.status.merged).to eq '**merged!**'
      end

      it 'is valid `status.closed`' do
        expect(settings.dictionary.status.closed).to eq '**closed!**'
      end
    end

    context 'given invalid settings' do
      let(:settings_yaml) { load_fixture('settings-invalid.yml') }

      it 'outputs YAML syntax error message' do
        expect { settings.dictionary }.to raise_error Psych::SyntaxError
      end
    end
  end
end
