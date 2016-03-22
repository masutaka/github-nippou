require 'active_support/time'
require 'octokit'

module Github
  module Nippou
    class UserEvents
      def initialize(client, user, since_date)
        @client = client
        @user = user
        @range = Time.parse(since_date)..Time.now.end_of_day
      end

      def retrieve
        user_events = @client.user_events(@user)
        last_response = @client.last_response

        while last_response.rels[:next] && in_range?(user_events.last)
          last_response = last_response.rels[:next].get
          user_events.concat(last_response.data)
        end

        user_events.select { |user_event| in_range?(user_event) }
      end

      private

      def in_range?(user_event)
        @range.include?(user_event.created_at.getlocal)
      end
    end
  end
end
