require 'json'
require 'ostruct'

module Github
  module Nippou
    class Settings
      def initialize(client:)
        @client = client
      end

      # Getting gist id which has settings.yml
      #
      # @return [String] gist id
      def gist_id
        @gist_id ||=
          begin
            ENV['GITHUB_NIPPOU_SETTINGS_GIST_ID'] ||
              begin
                git_config = `git config github-nippou.settings-gist-id`.chomp
                git_config.present? ? git_config : nil
              end
          end
      end

      # Create gist with config/settings.yml
      #
      # @return [Sawyer::Resource]
      def create_gist
        client.create_gist(
          description: 'github-nippou settings',
          public: true,
          files: { 'settings.yml' => { content: default_settings.to_yaml }}
        )
      end

      # Getting settings url
      #
      # @return [String]
      def url
        @url ||=
          if gist_id
            client.gist(gist_id).html_url
          else
            "https://github.com/masutaka/github-nippou/blob/v#{VERSION}/config/settings.yml"
          end
      end

      # Getting format settings
      #
      # @return [OpenStruct]
      def format
        open_struct(data[:format])
      end

      # Getting dictionary settings
      #
      # @return [OpenStruct]
      def dictionary
        open_struct(data[:dictionary])
      end

      private

      attr_reader :client

      # Getting default settings.yml as Hash
      #
      # return [Hash]
      def default_settings
        @default_settings ||=
          YAML.load_file(
            File.expand_path('../../../config/settings.yml', __dir__)
          )
      end

      # Getting settings data as Hash
      #
      # return [Hash]
      def data
        @data ||=
          begin
            if gist_id.present?
              gist = client.gist(gist_id)
              yaml_data = gist[:files][:'settings.yml'][:content]
              YAML.load(yaml_data).deep_symbolize_keys
            else
              default_settings.deep_symbolize_keys
            end
          rescue Psych::SyntaxError
            puts <<~MESSAGE
              ** YAML syntax error.

              #{$!.message}
              #{yaml_data}
            MESSAGE
            raise $!
          end
      end

      # Cast to OpenStruct
      #
      # @param hash [Hash]
      # @return [OpenStruct]
      def open_struct(hash)
        JSON.parse(hash.to_json, object_class: OpenStruct)
      end
    end
  end
end
