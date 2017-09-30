package lib

import (
	"context"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/google/go-github/github"
)

// List outputs formated GitHub events to stdout
func List(sinceDate, untilDate string) error {
	user, err := getUser()
	if err != nil {
		return err
	}

	accessToken, err := getAccessToken()
	if err != nil {
		return err
	}

	sinceTime, err := getSinceTime(sinceDate)
	if err != nil {
		log.Fatal(err)
	}

	untilTime, err := getUntilTime(untilDate)
	if err != nil {
		log.Fatal(err)
	}

	ctx := context.Background()
	client := getClient(ctx, accessToken)

	events := CollectEvents(ctx, client, user, sinceTime, untilTime)
	format := NewFormat(ctx, client)

	parallelNum, err := getParallelNum()
	if err != nil {
		return err
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
		return err
	}

	fmt.Print(allLines)

	return nil
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
