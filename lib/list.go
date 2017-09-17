package lib

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"sync"
	"time"

	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
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

	// fmt.Printf("sinceDate: %s, sinceTime: %s\n", sinceDate, sinceTime)
	// fmt.Printf("untilDate: %s, untilTime: %s\n", untilDate, untilTime)

	ctx := context.Background()
	client := getClient(ctx, accessToken)

	events := CollectEvents(ctx, client, user, sinceTime, untilTime)
	format := NewFormat(ctx, client)
	sem := make(chan int, 5)
	var lines Lines
	var wg sync.WaitGroup
	var mu sync.Mutex

	for i, event := range events {
		wg.Add(1)
		go func(event *github.Event, i int) {
			defer wg.Done()
			sem <- 1
			// fmt.Printf("%2d Start\n", i)
			line := format.Line(event, i)
			// fmt.Printf("%2d Finish\n", i)
			<-sem

			// fmt.Printf("%2d Lock\n", i)
			mu.Lock()
			defer mu.Unlock()
			lines = append(lines, line)
			// fmt.Printf("%2d Unlock\n", i)
		}(event, i)
	}
	wg.Wait()

	fmt.Print(format.All(lines))

	return nil
}

func getUser() (string, error) {
	if os.Getenv("GITHUB_NIPPOU_USER") != "" {
		return os.Getenv("GITHUB_NIPPOU_USER"), nil
	}

	output, _ := exec.Command("git", "config", "github-nippou.user").Output()

	if len(output) >= 1 {
		return strings.TrimRight(string(output), "\n"), nil
	}

	errText := `!!!! GitHub User required. Please execute the following command. !!!!

    $ github-nippou init`

	return "", errors.New(errText)
}

func getAccessToken() (string, error) {
	if os.Getenv("GITHUB_NIPPOU_ACCESS_TOKEN") != "" {
		return os.Getenv("GITHUB_NIPPOU_ACCESS_TOKEN"), nil
	}

	output, _ := exec.Command("git", "config", "github-nippou.token").Output()

	if len(output) >= 1 {
		return strings.TrimRight(string(output), "\n"), nil
	}

	errText := `!!!! GitHub Personal access token required. Please execute the following command. !!!!

    $ github-nippou init`

	return "", errors.New(errText)
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

func getClient(ctx context.Context, accessToken string) *github.Client {
	sts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: accessToken},
	)
	return github.NewClient(oauth2.NewClient(ctx, sts))
}
