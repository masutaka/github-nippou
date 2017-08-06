require 'json'
require 'ostruct'

module Github
  module Nippou
    class Settings
      def initialize(client:)
        @client = client
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

      # Getting settings as YAML format
      #
      # return [String]
      def yaml
        data.to_yaml
      end

      private

      attr_reader :client

      # Getting settings data as Hash
      #
      # return [Hash]
      def data
        @data ||=
          begin
            yaml_data =
              case
              when ENV['GITHUB_NIPPOU_SETTINGS']
                ENV['GITHUB_NIPPOU_SETTINGS'].chomp
              when !`git config github-nippou.settings`.chomp.empty?
                `git config github-nippou.settings`.chomp
              when !`git config github-nippou.settings-gist-id`.chomp.empty?
                gist_id = `git config github-nippou.settings-gist-id`.chomp
                gist = client.gist(gist_id)
                gist[:files][:'settings.yml'][:content]
              end

            if yaml_data
              YAML.load(yaml_data).deep_symbolize_keys
            else
              YAML.load_file(File.expand_path('../../../config/settings.yml', __dir__)).deep_symbolize_keys
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
