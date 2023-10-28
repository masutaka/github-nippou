package lib

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/google/go-github/github"
)

// Events represents a structure for fetching user-related events from the GitHub API.
// It holds the necessary parameters to filter and retrieve specific event data for a user.
type Events struct {
	ctx       context.Context
	client    *github.Client
	user      string
	sinceTime time.Time
	untilTime time.Time
	debug     bool
}

// NewEvents is an initializer
func NewEvents(ctx context.Context, client *github.Client, user string, sinceTime, untilTime time.Time, debug bool) *Events {
	return &Events{ctx: ctx, client: client, user: user, sinceTime: sinceTime, untilTime: untilTime, debug: debug}
}

// Collect retrieve GitHub `e.user` events from `e.sinceTime` to `e.untilTime`
func (e *Events) Collect() ([]*github.Event, error) {
	return e.uniq(e.filter(e.retrieve()))
}

func (e *Events) retrieve() []*github.Event {
	var allEvents []*github.Event
	opt := &github.ListOptions{Page: 1, PerPage: 100}

	for {
		events, response, err := e.client.Activity.ListEventsPerformedByUser(e.ctx, e.user, false, opt)
		if err != nil {
			log.Fatal(err)
		}

		allEvents = append(allEvents, events...)

		if !continueToRetrieve(response, events, e.sinceTime) {
			break
		}

		opt.Page = response.NextPage
	}

	return selectEventsInRange(allEvents, e.sinceTime, e.untilTime)
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

func (e *Events) filter(events []*github.Event) []*github.Event {
	var result []*github.Event

	for _, event := range events {
		if e.debug {
			format := NewFormat(e.ctx, e.client, Settings{}, false)
			fmt.Printf("[Debug] %s: %v\n", *event.Type, format.Line(event, 999))
		}

		switch *event.Type {
		case "IssuesEvent", "IssueCommentEvent", "PullRequestEvent", "PullRequestReviewCommentEvent", "PullRequestReviewEvent":
			result = append(result, event)
		}
	}

	return result
}

func (e *Events) uniq(events []*github.Event) ([]*github.Event, error) {
	m := make(map[string]bool)
	var result []*github.Event

	for _, event := range events {
		htmlURL, err := htmlURL(event)
		if err != nil {
			return nil, err
		}

		if !m[htmlURL] {
			m[htmlURL] = true
			result = append(result, event)
		}
	}

	return result, nil
}

func htmlURL(event *github.Event) (string, error) {
	var result string
	payload, err := event.ParsePayload()
	if err != nil {
		return "", err
	}

	switch *event.Type {
	case "IssuesEvent":
		result = *payload.(*github.IssuesEvent).Issue.HTMLURL
	case "IssueCommentEvent":
		result = *payload.(*github.IssueCommentEvent).Issue.HTMLURL
	case "PullRequestEvent":
		result = *payload.(*github.PullRequestEvent).PullRequest.HTMLURL
	case "PullRequestReviewCommentEvent":
		result = *payload.(*github.PullRequestReviewCommentEvent).PullRequest.HTMLURL
	case "PullRequestReviewEvent":
		result = *payload.(*github.PullRequestReviewEvent).PullRequest.HTMLURL
	}

	return result, nil
}
