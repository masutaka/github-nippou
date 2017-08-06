describe Github::Nippou::Settings do
  let(:client) { Octokit::Client.new(login: 'taro', access_token: '1234abcd') }
  let(:settings) { described_class.new(client: client) }

  before do
    ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = '12345'
    allow(client).to receive(:gist).and_return( files: { 'settings.yml': { content: settings_yaml } } )
  end

  describe '#format' do
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

  describe '#yaml' do
    context 'given valid settings' do
      let(:settings_yaml) { load_fixture('settings-valid.yml') }

      it 'is valid yaml' do
        expect(settings.yaml).to eq <<~VALID_YAML
          ---
          :format:
            :subject: "### %{subject}"
            :line: "* [%{title}](%{url}) by %{user} %{status}"
          :dictionary:
            :status:
              :merged: "**merged!**"
              :closed: "**closed!**"
        VALID_YAML
      end
    end

    context 'given invalid settings' do
      let(:settings_yaml) { load_fixture('settings-invalid.yml') }

      it 'outputs YAML syntax error message' do
        expect { settings.yaml }.to raise_error Psych::SyntaxError
      end
    end
  end
end
