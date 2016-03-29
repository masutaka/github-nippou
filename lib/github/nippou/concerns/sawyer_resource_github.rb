require 'octokit'

module SawyerResourceGithub
  refine Sawyer::Resource do
    def html_url
      case
      when self.issue?
        self.payload.issue.html_url
      when self.pull_request?
        self.payload.pull_request.html_url
      end
    end

    def issue?
      self.type == 'IssuesEvent' ||
        self.type == 'IssueCommentEvent'
    end

    def pull_request?
      self.type == 'PullRequestEvent' ||
        self.type == 'PullRequestReviewCommentEvent'
    end
  end
end
