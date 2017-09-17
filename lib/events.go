package lib

import (
	"context"
	"log"
	"time"

	"github.com/google/go-github/github"
)

// CollectEvents retrieve GitHub `user` events from `sinceTime` to `untilTime`
func CollectEvents(ctx context.Context, client *github.Client, user string, sinceTime, untilTime time.Time) []*github.Event {
	return uniq(filter(retrieve(ctx, client, user, sinceTime, untilTime)))
}

func retrieve(ctx context.Context, client *github.Client, user string, sinceTime, untilTime time.Time) []*github.Event {
	var allEvents []*github.Event
	opt := &github.ListOptions{Page: 1, PerPage: 100}

	for {
		events, response, err := client.Activity.ListEventsPerformedByUser(ctx, user, false, opt)
		if err != nil {
			log.Fatal(err)
		}

		allEvents = append(allEvents, events...)

		if !continueToRetrieve(response, events, sinceTime) {
			break
		}

		opt.Page = response.NextPage
	}

	return selectEventsInRange(allEvents, sinceTime, untilTime)
}

func continueToRetrieve(response *github.Response, events []*github.Event, sinceTime time.Time) bool {
	if response.NextPage == 0 {
		return false
	}

	lastEvent := *events[len(events)-1]

	if lastEvent.CreatedAt.Before(sinceTime.Add(-time.Nanosecond)) {
		return false
	}

	return true
}

func selectEventsInRange(events []*github.Event, sinceTime, untilTime time.Time) []*github.Event {
	var result []*github.Event

	for _, event := range events {
		if isRange(event, sinceTime, untilTime) {
			result = append(result, event)
		}
	}

	return result
}

func isRange(event *github.Event, sinceTime, untilTime time.Time) bool {
	return event.CreatedAt.After(sinceTime.Add(-time.Nanosecond)) &&
		event.CreatedAt.Before(untilTime.Add(time.Nanosecond))
}

func filter(events []*github.Event) []*github.Event {
	var result []*github.Event

	for _, event := range events {
		switch *event.Type {
		case "IssuesEvent", "IssueCommentEvent", "PullRequestEvent", "PullRequestReviewCommentEvent":
			result = append(result, event)
		}
	}

	return result
}

func uniq(events []*github.Event) []*github.Event {
	m := make(map[string]bool)
	var result []*github.Event

	for _, event := range events {
		htmlURL := htmlURL(event)

		if !m[htmlURL] {
			m[htmlURL] = true
			result = append(result, event)
		}
	}

	return result
}

func htmlURL(event *github.Event) string {
	var result string
	payload := event.Payload()

	switch *event.Type {
	case "IssuesEvent":
		result = *payload.(*github.IssuesEvent).Issue.HTMLURL
	case "IssueCommentEvent":
		result = *payload.(*github.IssueCommentEvent).Issue.HTMLURL
	case "PullRequestEvent":
		result = *payload.(*github.PullRequestEvent).PullRequest.HTMLURL
	case "PullRequestReviewCommentEvent":
		result = *payload.(*github.PullRequestReviewCommentEvent).PullRequest.HTMLURL
	}

	return result
}
