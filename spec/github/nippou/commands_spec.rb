require 'spec_helper'

describe Github::Nippou::Commands do
  let(:commands) { described_class.new }

  describe '#settings' do
    subject(:execute) { commands.send(:settings) }

    let(:settings) do
      {
        format: {
          subject: '### %{subject}',
          line: '* [%{title}](%{url}) by %{user} %{status}',
        },
      }
    end

    let(:yaml) { settings.to_yaml }

    context "when ENV['GITHUB_NIPPOU_SETTINGS'] present" do
      before { ENV['GITHUB_NIPPOU_SETTINGS'] = yaml }

      context 'given valid YAML syntax' do
        it 'should set YAML value to @settings' do
          expect { execute }
            .to change { commands.instance_variable_get(:@settings) }
            .to settings
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
              execute
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
