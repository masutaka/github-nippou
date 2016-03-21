require 'octokit'
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
      class_option :all, type: :boolean, aliases: :a, desc: 'Also displays GitHub events before today'
      class_option :num, type: :numeric, default: 50, aliases: :n, desc: 'GitHub event numbers that retrieve from GitHub'

      desc 'list', "Displays today's GitHub events formatted for Nippou"
      def list
        nippous.each do |url, detail|
          line = "* [#{detail[:title]} - #{detail[:repo_basename]}](#{url}) by #{detail[:username]}"
          line << ' **merged!**' if detail[:merged]
          puts line
        end
      end

      private

      def nippous
        result = {}
        now = Time.now

        client.user_events(user, per_page: options[:num]).each do |event|
          break if skip?(event, now)

          case event.type
          when 'IssuesEvent', 'IssueCommentEvent'
            issue = event.payload.issue
            result[issue.html_url] ||= hash_for_issue(event.repo, issue)
          when 'PullRequestEvent', 'PullRequestReviewCommentEvent'
            pr = event.payload.pull_request
            result[pr.html_url] ||= hash_for_pr(event.repo, pr)
          end
        end

        result
      end

      def skip?(event, now)
        if options[:all]
          false
        else
          event.created_at.getlocal.to_date != now.to_date
        end
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
        {title: title, repo_basename: repo.name, username: issue.user.login, merged: merged}
      end

      def hash_for_pr(repo, pr)
        title = pr.title.markdown_escape
        merged = client.pull_merged?(repo.name, pr.number)
        {title: title, repo_basename: repo.name, username: pr.user.login, merged: merged}
      end
    end
  end
end
