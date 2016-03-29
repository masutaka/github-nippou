require 'active_support/time'
require 'octokit'

module Github
  module Nippou
    class UserEvents
      using SawyerResourceGithub

      def initialize(client, user, since_date, until_date)
        @client = client
        @user = user
        @since_time = Time.parse(since_date).beginning_of_day
        until_time = Time.parse(until_date).end_of_day
        @range = @since_time..until_time
      end

      def collect
        uniq(filter(retrieve))
      end

      private

      def retrieve
        user_events = @client.user_events(@user, per_page: 100)
        last_response = @client.last_response

        while continue?(last_response, user_events)
          last_response = last_response.rels[:next].get
          user_events.concat(last_response.data)
        end

        user_events.select { |user_event| in_range?(user_event) }
      end

      def continue?(last_response, user_events)
        last_response.rels[:next] &&
          user_events.last.created_at.getlocal >= @since_time
      end

      def in_range?(user_event)
        @range.include?(user_event.created_at.getlocal)
      end

      def filter(user_events)
        user_events.select do |user_event|
          user_event.issue? || user_event.pull_request?
        end
      end

      def uniq(user_events)
        user_events.uniq do |user_event|
          user_event.html_url
        end
      end
    end
  end
end
