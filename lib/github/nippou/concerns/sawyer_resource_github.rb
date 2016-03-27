require 'octokit'

module SawyerResourceGithub
  refine Sawyer::Resource do
    def issue(client)
      case
      when self.issue?
        client.issue(self.repo.name, self.payload.issue.number)
      when self.pull_request?
        client.pull_request(self.repo.name, self.payload.pull_request.number)
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

    def html_url
      type = self.issue? ? :issue : :pull_request
      self.payload.try!(type).html_url
    end
  end
end
