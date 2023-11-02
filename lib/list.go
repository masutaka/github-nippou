package lib

import (
	"context"
	"sync"
	"time"

	"github.com/google/go-github/github"
)

// List is a struct for collecting GitHub activities.
type List struct {
	sinceDate      string
	untilDate      string
	user           string
	accessToken    string
	settingsGistID string
	debug          bool
}

// NewList returns a new List.
func NewList(sinceDate, untilDate, user, accessToken, settingsGistID string, debug bool) *List {
	return &List{
		sinceDate:      sinceDate,
		untilDate:      untilDate,
		user:           user,
		accessToken:    accessToken,
		settingsGistID: settingsGistID,
		debug:          debug,
	}
}

// NewListFromCLI returns a new List from environment variables or git config.
func NewListFromCLI(sinceDate, untilDate string, debug bool) (*List, error) {
	user, err := getUser()
	if err != nil {
		return nil, err
	}
	accessToken, err := getAccessToken()
	if err != nil {
		return nil, err
	}
	settingsGistID := getGistID()

	return &List{
		sinceDate:      sinceDate,
		untilDate:      untilDate,
		user:           user,
		accessToken:    accessToken,
		settingsGistID: settingsGistID,
		debug:          debug,
	}, nil
}

// Collect collects GitHub activities.
func (l *List) Collect() (string, error) {
	sinceTime, err := getSinceTime(l.sinceDate)
	if err != nil {
		return "", err
	}

	untilTime, err := getUntilTime(l.untilDate)
	if err != nil {
		return "", err
	}

	ctx := context.Background()
	client := getClient(ctx, l.accessToken)

	events, err := NewEvents(ctx, client, l.user, sinceTime, untilTime, l.debug).Collect()
	if err != nil {
		return "", err
	}
	var settings Settings
	if err = settings.Init(l.settingsGistID, l.accessToken); err != nil {
		return "", err
	}
	format := NewFormat(ctx, client, settings, l.debug)

	parallelNum, err := getParallelNum()
	if err != nil {
		return "", err
	}

	sem := make(chan int, parallelNum)
	var lines Lines
	var wg sync.WaitGroup
	var mu sync.Mutex

	for i, event := range events {
		wg.Add(1)
		go func(event *github.Event, i int) {
			defer wg.Done()
			sem <- 1
			line := format.Line(event, i)
			<-sem

			mu.Lock()
			defer mu.Unlock()
			lines = append(lines, line)
		}(event, i)
	}
	wg.Wait()

	allLines, err := format.All(lines)
	if err != nil {
		return "", err
	}

	return allLines, nil
}

func getSinceTime(sinceDate string) (time.Time, error) {
	return time.Parse("20060102 15:04:05 MST", sinceDate+" 00:00:00 "+getZoneName())
}

func getUntilTime(untilDate string) (time.Time, error) {
	result, err := time.Parse("20060102 15:04:05 MST", untilDate+" 00:00:00 "+getZoneName())
	if err != nil {
		return result, err
	}

	return result.AddDate(0, 0, 1).Add(-time.Nanosecond), nil
}

func getZoneName() string {
	zone, _ := time.Now().Zone()
	return zone
}
