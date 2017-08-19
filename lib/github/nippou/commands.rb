require 'launchy'
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

      desc 'list', "Print today's your GitHub action (Default)"
      def list
        lines = []
        mutex = Mutex.new
        format = Format.new(settings, debug)

        Parallel.each_with_index(user_events, in_threads: settings.thread_num) do |user_event, i|
          # Contain GitHub access.
          # So should not put into the mutex block.
          line = format.line(user_event, i)
          mutex.synchronize { lines << line }
        end

        puts format.all(lines)
      end

      desc 'init', 'Initialize github-nippou settings'
      def init
        Init.new(settings: settings).run
      end

      desc 'open-settings', 'Open settings url with web browser'
      def open_settings
        puts "Open #{settings.url}"
        Launchy.open(settings.url)
      end

      desc 'version', 'Print version'
      def version
        puts VERSION
      end

      private

      def user_events
        @user_events ||= UserEvents.new(
          settings.client, settings.user, options[:since_date], options[:until_date]
        ).collect
      end

      def settings
        @settings ||= Settings.new
      end

      def debug
        @debug ||= options[:debug]
      end
    end
  end
end
