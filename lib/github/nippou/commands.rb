require 'thor'

module StringExMarkdown
  refine String do
    def markdown_escape
      self.gsub(/([`<>])/, '\\\\\1')
    end
  end
end

module Github
  module Nippou
    class Commands < Thor
      using StringExMarkdown

      default_task :list
      class_option :since_date, type: :string,
                   default: Time.now.strftime('%Y%m%d'),
                   aliases: :s, desc: 'Retrieves GitHub user_events since the date'

      desc 'list', "Displays today's GitHub events formatted for Nippou"
      def list
        nippous.each do |url, detail|
          line = "* [#{detail[:title]} - #{detail[:repo_basename]}](#{url}) by #{detail[:username]}"
          if detail[:merged]
            line << ' **merged!**'
          elsif detail[:state] == 'closed'
            line << ' **closed!**'
          end
          puts line
        end
      end

      private

      def nippous
        result = {}

        user_events.each do |user_event|
          case user_event.type
          when 'IssuesEvent', 'IssueCommentEvent'
            issue = user_event.payload.issue
            result[issue.html_url] ||= hash_for_issue(user_event.repo, issue)
          when 'PullRequestEvent', 'PullRequestReviewCommentEvent'
            pr = user_event.payload.pull_request
            result[pr.html_url] ||= hash_for_pr(user_event.repo, pr)
          end
        end

        result.sort
      end

      def user_events
        @user_events ||= UserEvents.new(
          client, user, options[:since_date]
        ).retrieve
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

To get new token, visit
https://github.com/settings/tokens/new
MESSAGE
            exit!
          end
      end

      def hash_for_issue(repo, issue)
        title = issue.title.markdown_escape
        merged = client.pull_merged?(repo.name, issue.number)
        state = client.issue(repo.name, issue.number).state
        {title: title, repo_basename: repo.name, username: issue.user.login, merged: merged, state: state}
      end

      def hash_for_pr(repo, pr)
        title = pr.title.markdown_escape
        merged = client.pull_merged?(repo.name, pr.number)
        state = client.pull_request(repo.name, pr.number).state
        {title: title, repo_basename: repo.name, username: pr.user.login, merged: merged, state: state}
      end
    end
  end
end
