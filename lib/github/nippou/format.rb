module Github
  module Nippou
    class Format
      using SawyerResourceGithub
      using StringMarkdown

      # @param client [Octokit::Client]
      # @param thread_num [Integer]
      # @param settings [Settings]
      # @param debug [Boolean]
      def initialize(client, thread_num, settings, debug)
        @client = client
        @thread_num = thread_num
        @settings = settings
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
            result << "\n#{format_subject(current_repo_name)}\n\n"
          end

          result << "#{format_line(line)}\n"
        end

        result
      end

      private

      attr_reader :settings

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
        return nil if status.nil?
        settings.dictionary.status.send(status)
      end

      def format_subject(subject)
        sprintf(settings.format.subject, subject: subject)
      end

      def format_line(line)
        sprintf(
          settings.format.line,
          title: line[:title].markdown_escape,
          url: line[:url],
          user: line[:user],
          status: format_status(line[:status])
        ).strip
      end
    end
  end
end
