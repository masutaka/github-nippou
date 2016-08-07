module Github
  module Nippou
    class Format
      using SawyerResourceGithub
      using StringMarkdown

      def initialize(client, thread_num, debug)
        @client = client
        @thread_num = thread_num
        @debug = debug
      end

      def line(user_event, i)
        STDERR.puts "#{i % @thread_num} : #{user_event.html_url}\n" if @debug
        issue = issue(user_event)
        line = "* [%s - %s](%s) by %s" %
               [issue.title.markdown_escape, user_event.repo.name, user_event.html_url, issue.user.login]

        if issue.merged
          line << ' **merged!**'
        elsif issue.state == 'closed'
          line << ' **closed!**'
        end

        line
      end

      private

      def issue(user_event)
        case
        when user_event.payload.pull_request
          @client.pull_request(user_event.repo.name, user_event.payload.pull_request.number)
        when user_event.payload.issue.pull_request
          # a pull_request like an issue
          @client.pull_request(user_event.repo.name, user_event.payload.issue.number)
        else
          @client.issue(user_event.repo.name, user_event.payload.issue.number)
        end
      end
    end
  end
end
