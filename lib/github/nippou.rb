require 'github/nippou/version'
require 'octokit'

module Github
  module Nippou
    class << self
      def list
        client = Octokit::Client.new(login: user, access_token: access_token)
        events = client.user_events(user)

        url_to_detail = {}
        now = Time.now

        events.each do |e|
          break unless e.created_at.getlocal.to_date == now.to_date
          case e.type
          when 'IssuesEvent', 'IssueCommentEvent'
            issue = e.payload.issue
            title = issue.title.gsub('`', '\\\`')
            merged = client.pull_merged?(e.repo.name, issue.number)
            url_to_detail[issue.html_url] ||= {title: title, repo_basename: e.repo.name, username: issue.user.login, merged: merged}
          when 'PullRequestEvent', 'PullRequestReviewCommentEvent'
            pr = e.payload.pull_request
            title = pr.title.gsub('`', '\\\`')
            merged = client.pull_merged?(e.repo.name, pr.number)
            url_to_detail[pr.html_url] ||= {title: title, repo_basename: e.repo.name, username: pr.user.login, merged: merged}
          end
        end

        url_to_detail.each do |url, detail|
          line = "* [#{detail[:title]} - #{detail[:repo_basename]}](#{url}) by #{detail[:username]}"
          line << ' **merged!**' if detail[:merged]
          puts line
        end
      end

      private

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
