# frozen_string_literal: true

describe Github::Nippou::Settings do
  let(:settings) { described_class.new }

  it_behaves_like 'a settings interface'

  describe '#user' do
    before { ENV['GITHUB_NIPPOU_USER'] = 'taro' }
    subject { settings.user }
    it { is_expected.to eq 'taro' }
    after { ENV['GITHUB_NIPPOU_USER'] = nil }
  end

  describe '#access_token' do
    before { ENV['GITHUB_NIPPOU_ACCESS_TOKEN'] = '1234abcd' }
    subject { settings.access_token }
    it { is_expected.to eq '1234abcd' }
    after { ENV['GITHUB_NIPPOU_ACCESS_TOKEN'] = nil }
  end

  describe '#gist_id' do
    before { ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = '0123456789' }
    subject { settings.gist_id }
    it { is_expected.to eq '0123456789' }
    after { ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] = nil }
  end

  describe '#thread_num' do
    before { ENV['GITHUB_NIPPOU_THREAD_NUM'] = '10' }
    subject { settings.thread_num }
    it { is_expected.to eq 10 }
    after { ENV['GITHUB_NIPPOU_THREAD_NUM'] = nil }
  end

  describe '#url' do
    subject { settings.url }

    context 'given gist_id' do
      let(:gist_id) { '0123456789' }

      before do
        allow(settings).to receive(:gist_id).and_return gist_id
        allow(settings).to receive_message_chain(:client, :gist) do
          OpenStruct.new(html_url: "https://gist.github.com/#{gist_id}")
        end
      end

      it { is_expected.to eq "https://gist.github.com/#{gist_id}" }
    end

    context 'given no gist_id' do
      before { allow(settings).to receive(:gist_id).and_return nil }
      it { is_expected.to eq "https://github.com/masutaka/github-nippou/blob/v#{Github::Nippou::VERSION}/config/settings.yml" }
    end
  end

  describe '#default_url' do
    subject { settings.default_url }
    it { is_expected.to eq "https://github.com/masutaka/github-nippou/blob/v#{Github::Nippou::VERSION}/config/settings.yml" }
  end

  describe '#format' do
    before do
      allow(settings).to receive(:gist_id).and_return '12345'
      allow(settings).to receive_message_chain(:client, :gist) do
        OpenStruct.new(files: { 'settings.yml': { content: settings_yaml } })
      end
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
      allow(settings).to receive(:gist_id).and_return '12345'
      allow(settings).to receive_message_chain(:client, :gist) do
        OpenStruct.new(files: { 'settings.yml': { content: settings_yaml } })
      end
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
