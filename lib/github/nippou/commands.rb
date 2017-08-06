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

            You need personal access token which has `gist` scope.
            Please add `gist` scope to your personal access token, visit
            https://github.com/settings/tokens
          MESSAGE
          exit!
        end

        if settings.gist_id.present?
          puts <<~MESSAGE
            ** Already initialized.

            It already have gist id that github-nippou.settings-gist-id on your .gitconfig.
          MESSAGE
          exit
        end

        gist = settings.create_gist
        `git config --global github-nippou.settings-gist-id #{gist[:id]}`

        puts <<~MESSAGE
          The github-nippou settings was created on #{gist[:html_url]}

          And the gist_id was appended to your .gitconfig. You can
          check the gist_id with following command.

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

              To get new token with `repo` and `gist` scope, visit
              https://github.com/settings/tokens/new
            MESSAGE
            exit!
          end
      end

      def settings
        @settings ||= Settings.new(client: client)
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
