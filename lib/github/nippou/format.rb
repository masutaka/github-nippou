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

        line = {
          title: issue.title,
          repo_name: user_event.repo.name,
          url: user_event.html_url,
          user: issue.user.login,
        }

        line[:status] =
          if issue.merged
            :merged
          elsif issue.state == 'closed'
            :closed
          end

        line
      end

      def all(lines)
        result = ""
        prev_repo_name = nil
        current_repo_name = nil

        sort(lines).each do |line|
          current_repo_name = line[:repo_name]

          unless current_repo_name == prev_repo_name
            prev_repo_name = current_repo_name
            result << "\n### #{current_repo_name}\n\n"
          end

          result << "* [%s](%s) by %s%s\n" %
            [line[:title].markdown_escape, line[:url], line[:user], format_status(line[:status])]
        end

        result
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

      def sort(lines)
        lines.sort { |a, b| a[:url] <=> b[:url] }
      end

      def format_status(status)
        case status
        when :merged
          ' **merged!**'
        when :closed
          ' **closed!**'
        else
          ''
        end
      end
    end
  end
end
