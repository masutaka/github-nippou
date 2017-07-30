require 'parallel'
require 'thor'

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
        format = Format.new(client, thread_num, debug)

        Parallel.each_with_index(user_events, in_threads: thread_num) do |user_event, i|
          # Contain GitHub access.
          # So should not put into the mutex block.
          line = format.line(user_event, i)
          mutex.synchronize { lines << line }
        end

        puts format.all(lines)
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
            puts <<MESSAGE
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
            puts <<MESSAGE
** Authorization required.

Please set github-nippou.token to your .gitconfig.
    $ git config --global github-nippou.token [Your GitHub access token]

To get new token with `repo` scope, visit
https://github.com/settings/tokens/new
MESSAGE
            exit!
          end
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
