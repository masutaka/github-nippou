describe Github::Nippou::Settings do
  describe '#data' do
    let(:client) { Octokit::Client.new(login: 'taro', access_token: '1234abcd') }
    let(:settings) { described_class.new(client: client) }

    let(:settings_format) do
      {
        format: {
          subject: '### %{subject}',
          line: '* [%{title}](%{url}) by %{user} %{status}',
        },
      }
    end

    context "when ENV['GITHUB_NIPPOU_SETTINGS'] present" do
      before { ENV['GITHUB_NIPPOU_SETTINGS'] = settings_format.to_yaml }

      context 'given valid YAML syntax' do
        it 'should set YAML value to @settings' do
          expect(settings.data).to eq settings_format
        end
      end

      context 'given invalid YAML syntax' do
        before do
          ENV['GITHUB_NIPPOU_SETTINGS'] = <<~INVALID_YAML
            format:
              **!!invalid!!**
              line: '* [%{title}](%{url}) by %{user} %{status}'
          INVALID_YAML
        end

        it 'should output YAML syntax error message' do
          expect {
            begin
              settings.data
            rescue SystemExit
              nil
            end
          }.to output(<<~ERROR).to_stdout
            ** YAML syntax error.

            (<unknown>): did not find expected alphabetic or numeric character while scanning an alias at line 2 column 3
            format:
              **!!invalid!!**
              line: '* [%{title}](%{url}) by %{user} %{status}'
          ERROR
        end
      end
    end
  end
end
