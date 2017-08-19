require 'highline/import'

module Github
  module Nippou
    class Init
      # @param settings [Settings]
      def initialize(settings:)
        @settings = settings
      end

      # Run the initialization
      #
      # @raise [SystemExit] failed the initialization,
      #   or don't need, or canceled
      def run
        puts '** github-nippou Initialization **'
        set_user!
        sleep 0.5
        set_access_token!
        sleep 0.5
        create_and_set_gist!
      end

      private

      attr_reader :settings

      def set_user!
        puts <<~MESSAGE

          == [Step: 1/3] GitHub user ==

        MESSAGE

        begin
          settings.user(verbose: false)
          msg = 'Already initialized.'
        rescue Github::Nippou::Settings::GettingUserError
          user = HighLine.new.ask("What's your GitHub account? ")

          if user.present?
            puts <<~MESSAGE

              The following command will be executed.

                  $ git config --global github-nippou.user #{user}

            MESSAGE

            unless HighLine.agree('Are you sure? [y/n] ')
              puts 'Canceled.'
              abort
            end

            `git config --global github-nippou.user #{user}`
            msg = 'Thanks!'
          end
        end

        puts <<~MESSAGE
          #{msg} You can get it with the following command.

              $ git config --global github-nippou.user

        MESSAGE
      end

      def set_access_token!
        puts <<~MESSAGE

          == [Step: 2/3] GitHub personal access token ==

          To get new token with `repo` and `gist` scope, visit
          https://github.com/settings/tokens/new

        MESSAGE

        begin
          settings.access_token(verbose: false)
          msg = 'Already initialized.'
        rescue Github::Nippou::Settings::GettingAccessTokenError
          token = HighLine.new.ask("What's your GitHub personal access token? ")

          if token.present?
            puts <<~MESSAGE

              The following command will be executed.

                  $ git config --global github-nippou.token #{token}

            MESSAGE

            unless HighLine.agree('Are you sure? [y/n] ')
              puts 'Canceled.'
              abort
            end

            `git config --global github-nippou.token #{token}`
            msg = 'Thanks!'
          end
        end

        puts <<~MESSAGE
          #{msg} You can get it with the following command.

              $ git config --global github-nippou.token

        MESSAGE

        unless settings.client.scopes.include?('repo') &&
               settings.client.scopes.include?('gist')
          puts <<~MESSAGE
            !!!! `repo` and `gist` scopes are required. !!!!

            You need personal access token which has `repo` and `gist`
            scopes. Please add these scopes to your personal access
            token, visit https://github.com/settings/tokens

          MESSAGE
          abort
        end
      end

      def create_and_set_gist!
        puts <<~MESSAGE

          == [Step: 3/3] Gist (optional) ==

        MESSAGE

        if settings.gist_id.present?
          msg = 'Already initialized.'
        else
          puts <<~MESSAGE
            1. Create a gist with the content of #{settings.default_url}
            2. The following command will be executed

                $ git config --global github-nippou.settings-gist-id <created gist id>

          MESSAGE

          unless HighLine.agree('Are you sure? [y/n] ')
            puts 'Canceled.'
            abort
          end

          gist = settings.create_gist
          `git config --global github-nippou.settings-gist-id #{gist.id}`
          msg = 'Thanks!'
        end

        puts <<~MESSAGE
          #{msg} You can get it with the following command.

              $ git config --global github-nippou.settings-gist-id

          And you can easily open the gist URL with web browser.

              $ github-nippou open-settings

        MESSAGE
      end
    end
  end
end
