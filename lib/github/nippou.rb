require "github/nippou/version"
require 'octokit'

module Github
  module Nippou
    def self.list
      user = self.user
      client = Octokit::Client.new(login: user, access_token: self.access_token)
      events = client.user_events(user)

      url_to_detail = {}

      events.each do |_|
        break unless _.created_at.getlocal.to_date == Time.now.to_date
        case _.type
        when "IssuesEvent"
          url_to_detail[_.payload.issue.html_url] ||= {title: _.payload.issue.title, comments: []}
        when "IssueCommentEvent"
          url_to_detail[_.payload.issue.html_url] ||= {title: _.payload.issue.title, comments: []}
          url_to_detail[_.payload.issue.html_url][:comments] << _.payload.comment.html_url
        when "PullRequestEvent"
          url_to_detail[_.payload.pull_request.html_url] ||= {title: _.payload.pull_request.title, comments: []}
        end
      end

      url_to_detail.each do |url, detail|
        puts "- #{detail[:title]} #{url}"
        detail[:comments].reverse.each do |comment|
          puts "  * #{comment}"
        end
      end
    end

    private

    def self.user
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

    def self.access_token
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
  end
end
