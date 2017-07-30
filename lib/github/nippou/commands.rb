require 'parallel'
require 'thor'
require 'yaml'

module Github
  module Nippou
    class Commands < Thor
      default_task :list
      class_option :since_date, type: :string,
                   default: Time.now.strftime('%Y%m%d'),
                   aliases: :s, desc: 'Retrieves GitHub user_events since the date'
      class_option :until_date, type: :string,
                   default: Time.now.strftime('%Y%m%d'),
                   aliases: :u, desc: 'Retrieves GitHub user_events until the date'
      class_option :debug, type: :boolean, default: false, aliases: :d, desc: 'Debug mode'

      desc 'list', "Displays today's GitHub events formatted for Nippou"
      def list
        lines = []
        mutex = Mutex.new
        format = Format.new(client, thread_num, settings, debug)

        Parallel.each_with_index(user_events, in_threads: thread_num) do |user_event, i|
          # Contain GitHub access.
          # So should not put into the mutex block.
          line = format.line(user_event, i)
          mutex.synchronize { lines << line }
        end

        puts format.all(lines)
      end

      desc 'init', 'Synchronize github-nippou settings on your gist'
      def init
        unless client.scopes.include? 'gist'
          puts <<~MESSAGE
            ** Gist scope required.

            You need personal access token which has gist scope.
            Please add gist scope on your personal access token if you use this command.
          MESSAGE
          exit!
        end
        unless `git config github-nippou.settings-gist-id`.chomp.empty?
          puts <<~MESSAGE
            ** Already initialized.

            It already have gist id that github-nippou.settings-gist-id on your .gitconfig.
          MESSAGE
          exit!
        end

        result = client.create_gist(
          description: 'github-nippou settings',
          public: true,
          files: { 'settings.yml' => { content: settings.to_yaml }}
        ).to_h
        `git config --global github-nippou.settings-gist-id #{result[:id]}`

        puts <<~MESSAGE
          The github-nippou settings was created on following url: #{result[:html_url]}
          And the gist id was set your .gitconfig
          You can check the gist id with following command
              $ git config --global github-nippou.settings-gist-id
        MESSAGE
      end

      desc 'version', 'Displays version'
      def version
        puts VERSION
      end

      private

      def user_events
        @user_events ||= UserEvents.new(
          client, user, options[:since_date], options[:until_date]
        ).collect
      end

      def client
        @client ||= Octokit::Client.new(login: user, access_token: access_token)
      end

      def user
        @user ||=
          case
          when ENV['GITHUB_NIPPOU_USER']
            ENV['GITHUB_NIPPOU_USER']
          when !`git config github-nippou.user`.chomp.empty?
            `git config github-nippou.user`.chomp
          else
            puts <<~MESSAGE
              ** User required.

              Please set github-nippou.user to your .gitconfig.
                  $ git config --global github-nippou.user [Your GitHub account]
            MESSAGE
            exit!
          end
      end

      def access_token
        @access_token ||=
          case
          when ENV['GITHUB_NIPPOU_ACCESS_TOKEN']
            ENV['GITHUB_NIPPOU_ACCESS_TOKEN']
          when !`git config github-nippou.token`.chomp.empty?
            `git config github-nippou.token`.chomp
          else
            puts <<~MESSAGE
              ** Authorization required.

              Please set github-nippou.token to your .gitconfig.
                  $ git config --global github-nippou.token [Your GitHub access token]

              To get new token with `repo` scope, visit
              https://github.com/settings/tokens/new
            MESSAGE
            exit!
          end
      end

      def settings
        return @settings if @settings.present?

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

        @settings =
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

      def thread_num
        @thread_num ||=
          case
          when ENV['GITHUB_NIPPOU_THREAD_NUM']
            ENV['GITHUB_NIPPOU_THREAD_NUM']
          when !`git config github-nippou.thread-num`.chomp.empty?
            `git config github-nippou.thread-num`.chomp
          else
            5
          end.to_i
      end

      def debug
        @debug ||= options[:debug]
      end
    end
  end
end
