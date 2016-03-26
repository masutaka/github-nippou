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
$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "aaa: #{$t_after - $t_before}";
$t_before = $t_after
        user_events = @client.user_events(@user, per_page: 100)
$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "bbb: #{$t_after - $t_before}";
$t_before = $t_after
        last_response = @client.last_response
$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "ccc: #{$t_after - $t_before}";
$t_before = $t_after

        while last_response.rels[:next] && in_range?(user_events.last)
$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "ddd: #{$t_after - $t_before}";
$t_before = $t_after
          last_response = last_response.rels[:next].get
$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "eee: #{$t_after - $t_before}";
$t_before = $t_after
          user_events.concat(last_response.data)
$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "fff: #{$t_after - $t_before}";
$t_before = $t_after
        end

$t_after = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
puts "ggg: #{$t_after - $t_before}";
$t_before = $t_after
        user_events.select { |user_event| in_range?(user_event) }
      end

      private

      def in_range?(user_event)
        @range.include?(user_event.created_at.getlocal)
      end
    end
  end
end
