require "github/nippou/version"
require 'octokit'

module Github
  module Nippou
    def list
      client = Octokit::Client.new(login: 'kitak', access_token: 'githubの/settings/applicationsで発行したトークン')
      events = client.user_events('kitak')

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
  end
end
