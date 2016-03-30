require 'octokit'

module SawyerResourceGithub
  refine Sawyer::Resource do
    def html_url
      if self.payload.pull_request
        self.payload.pull_request.html_url
      else
        self.payload.issue.html_url
      end
    end
  end
end
