module Github
  module Nippou
    class Settings
      def initialize(client:)
        @client = client
      end

      # Getting settings data
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
          rescue Psych::SyntaxError => e
            puts <<~MESSAGE
              ** YAML syntax error.

              #{e.message}
              #{yaml_data}
            MESSAGE
            exit
          end
      end

      private

      attr_reader :client
    end
  end
end
