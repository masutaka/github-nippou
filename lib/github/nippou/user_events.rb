require 'active_support/time'
require 'octokit'

module Github
  module Nippou
    class UserEvents
      def initialize(client, user, since_date, until_date)
        @client = client
        @user = user
        @since_date = Time.parse(since_date).beginning_of_day
        @until_date = Time.parse(until_date).end_of_day
        @range = @since_date..@until_date
      end

      def retrieve
        user_events = @client.user_events(@user, per_page: 100)
        last_response = @client.last_response

        while continue?(last_response, user_events)
          last_response = last_response.rels[:next].get
          user_events.concat(last_response.data)
        end

        user_events.select { |user_event| in_range?(user_event) }
      end

      private

      def continue?(last_response, user_events)
        last_response.rels[:next] &&
          user_events.last.created_at.getlocal >= @since_date
      end

      def in_range?(user_event)
        @range.include?(user_event.created_at.getlocal)
      end
    end
  end
end
