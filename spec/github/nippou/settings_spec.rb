describe Github::Nippou::Settings do
  let(:client) { Octokit::Client.new(login: 'taro', access_token: '1234abcd') }
  let(:settings) { described_class.new(client: client) }

  describe '#format' do
    context 'given valid settings' do
      let(:settings_format) do
        {
          format: {
            subject: '### %{subject}',
            line: '* [%{title}](%{url}) by %{user} %{status}',
          },
        }
      end

      before { ENV['GITHUB_NIPPOU_SETTINGS'] = settings_format.to_yaml }

      it 'is valid `subject`' do
        expect(settings.format.subject).to eq '### %{subject}'
      end

      it 'is valid `line`' do
        expect(settings.format.line).to eq '* [%{title}](%{url}) by %{user} %{status}'
      end
    end

    context 'given invalid settings' do
      let(:settings_format_yaml) do
        <<~INVALID_YAML
        format:
          **!!invalid!!**
          line: '* [%{title}](%{url}) by %{user} %{status}'
        INVALID_YAML
      end

      before { ENV['GITHUB_NIPPOU_SETTINGS'] = settings_format_yaml }

      it 'outputs YAML syntax error message' do
        expect do
          begin
            settings.format
          rescue SystemExit
            nil
          end
        end.to output(<<~ERROR).to_stdout
            ** YAML syntax error.

            (<unknown>): did not find expected alphabetic or numeric character while scanning an alias at line 2 column 3
            format:
              **!!invalid!!**
              line: '* [%{title}](%{url}) by %{user} %{status}'
          ERROR
      end
    end
  end

  describe '#dictionary' do
    context 'given valid settings' do
      let(:settings_dictionary) do
        {
          dictionary: {
            status: {
              merged: '**merged!**',
              closed: '**closed!**',
            },
          },
        }
      end

      before { ENV['GITHUB_NIPPOU_SETTINGS'] = settings_dictionary.to_yaml }

      it 'is valid `status.merged`' do
        expect(settings.dictionary.status.merged).to eq '**merged!**'
      end

      it 'is valid `status.closed`' do
        expect(settings.dictionary.status.closed).to eq '**closed!**'
      end
    end
  end

  describe '#yaml' do
    context 'given valid settings' do
      let(:settings_yaml) do
        <<~VALID_YAML
        format:
          subject: "### %{subject}"
          line: "* [%{title}](%{url}) by %{user} %{status}"
        dictionary:
          status:
            merged: "**merged!**"
            closed: "**closed!**"
        VALID_YAML
      end

      before { ENV['GITHUB_NIPPOU_SETTINGS'] = settings_yaml }

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
  end
end
