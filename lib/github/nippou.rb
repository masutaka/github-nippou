require 'github/nippou/version'
require 'octokit'

module StringExMarkdown
  refine String do
    def markdown_escape
      self.gsub('`', '\\\`')
    end
  end
end

module Github
  module Nippou
    class << self
      using StringExMarkdown

      def list
        nippous = {}
        now = Time.now

        client.user_events(user).each do |e|
          break unless e.created_at.getlocal.to_date == now.to_date
          case e.type
          when 'IssuesEvent', 'IssueCommentEvent'
            issue = e.payload.issue
            title = issue.title.markdown_escape
            merged = client.pull_merged?(e.repo.name, issue.number)
            nippous[issue.html_url] ||= {title: title, repo_basename: e.repo.name, username: issue.user.login, merged: merged}
          when 'PullRequestEvent', 'PullRequestReviewCommentEvent'
            pr = e.payload.pull_request
            title = pr.title.markdown_escape
            merged = client.pull_merged?(e.repo.name, pr.number)
            nippous[pr.html_url] ||= {title: title, repo_basename: e.repo.name, username: pr.user.login, merged: merged}
          end
        end

        nippous.each do |url, detail|
          line = "* [#{detail[:title]} - #{detail[:repo_basename]}](#{url}) by #{detail[:username]}"
          line << ' **merged!**' if detail[:merged]
          puts line
        end
      end

      private

      def client
        @client ||= Octokit::Client.new(login: user, access_token: access_token)
      end

      def user
        @user ||= case
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
        @access_token ||= case
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
    end
  end
end
