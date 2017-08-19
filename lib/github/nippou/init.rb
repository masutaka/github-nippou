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
        unless settings.client.scopes.include? 'gist'
          puts <<~MESSAGE
            ** Gist scope required.

            You need personal access token which has `gist` scope.
            Please add `gist` scope to your personal access token, visit
            https://github.com/settings/tokens
          MESSAGE
          abort
        end

        if settings.gist_id.present?
          puts <<~MESSAGE
            ** Already initialized.

            Your `~/.gitconfig` already has gist_id as `github-nippou.settings-gist-id`.
          MESSAGE
          exit
        end

        puts 'This command will create a gist and update your `~/.gitconfig`.'

        unless HighLine.agree('Are you sure? [y/n] ')
          puts 'Canceled.'
          abort
        end

        gist = settings.create_gist
        `git config --global github-nippou.settings-gist-id #{gist.id}`

        puts <<~MESSAGE
          The github-nippou settings was created on #{gist.html_url}

          And the gist_id was appended to your `~/.gitconfig`. You can
          check the gist_id with following command.

              $ git config --global github-nippou.settings-gist-id
        MESSAGE
      end

      private

      attr_reader :settings
    end
  end
end
