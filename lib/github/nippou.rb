require 'github/nippou/version'
require 'octokit'

module Github
  module Nippou
    class << self
      def list
        client = Octokit::Client.new(login: user, access_token: access_token)
        events = client.user_events(user)

        url_to_detail = {}

        events.each do |_|
          break unless _.created_at.getlocal.to_date == Time.now.to_date
          case _.type
          when 'IssuesEvent', 'IssueCommentEvent'
            title = _.payload.issue.title.gsub('`', '\\\`')
            merged = client.pull_merged?(_.repo.name, _.payload.issue.number)
            url_to_detail[_.payload.issue.html_url] ||= {title: title, repo_basename: _.repo.name, username: _.payload.issue.user.login, merged: merged}
          when 'PullRequestEvent', 'PullRequestReviewCommentEvent'
            title = _.payload.pull_request.title.gsub('`', '\\\`')
            merged = client.pull_merged?(_.repo.name, _.payload.pull_request.number)
            url_to_detail[_.payload.pull_request.html_url] ||= {title: title, repo_basename: _.repo.name, username: _.payload.pull_request.user.login, merged: merged}
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
