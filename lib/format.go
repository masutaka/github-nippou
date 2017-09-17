package lib

import (
	"context"
	"fmt"
	"sort"
	"strings"

	"github.com/google/go-github/github"
)

// Format is Formatter
type Format struct {
	ctx    context.Context
	client *github.Client
}

// NewFormat is an initializer
func NewFormat(ctx context.Context, client *github.Client) *Format {
	return &Format{ctx: ctx, client: client}
}

// Line is line infomation
type Line struct {
	title    string
	repoName string
	url      string
	user     string
	status   string
}

// Line returns Issue/PR info retrieving from GitHub
func (f *Format) Line(event *github.Event, i int) Line {
	fmt.Printf("%2d %s\n", i, htmlURL(event))

	payload := event.Payload()
	var line Line

	switch *event.Type {
	case "IssuesEvent":
		e := payload.(*github.IssuesEvent)
		issue := getIssue(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)

		if issue.PullRequestLinks == nil {
			line = Line{
				title:    *issue.Title,
				repoName: *event.Repo.Name,
				url:      *issue.HTMLURL,
				user:     *issue.User.Login,
				status:   getIssueStatus(issue),
			}
		} else {
			pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)

			line = Line{
				title:    *pr.Title,
				repoName: *event.Repo.Name,
				url:      *pr.HTMLURL,
				user:     *pr.User.Login,
				status:   getPullRequestStatus(pr),
			}
		}
	case "IssueCommentEvent":
		e := payload.(*github.IssueCommentEvent)
		issue := getIssue(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)

		if issue.PullRequestLinks == nil {
			line = Line{
				title:    *issue.Title,
				repoName: *event.Repo.Name,
				url:      *issue.HTMLURL,
				user:     *issue.User.Login,
				status:   getIssueStatus(issue),
			}
		} else {
			pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)

			line = Line{
				title:    *pr.Title,
				repoName: *event.Repo.Name,
				url:      *pr.HTMLURL,
				user:     *pr.User.Login,
				status:   getPullRequestStatus(pr),
			}
		}
	case "PullRequestEvent":
		e := payload.(*github.PullRequestEvent)
		pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, e.GetNumber())
		line = Line{
			title:    *pr.Title,
			repoName: *event.Repo.Name,
			url:      *pr.HTMLURL,
			user:     *pr.User.Login,
			status:   getPullRequestStatus(pr),
		}
	case "PullRequestReviewCommentEvent":
		e := payload.(*github.PullRequestReviewCommentEvent)
		pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.PullRequest.Number)
		line = Line{
			title:    *pr.Title,
			repoName: *event.Repo.Name,
			url:      *pr.HTMLURL,
			user:     *pr.User.Login,
			status:   getPullRequestStatus(pr),
		}
	}

	return line
}

func getIssue(ctx context.Context, client *github.Client, repoFullName string, number int) *github.Issue {
	owner, repo := getOwnerRepo(repoFullName)
	issue, _, _ := client.Issues.Get(ctx, owner, repo, number)
	return issue
}

func getPullRequest(ctx context.Context, client *github.Client, repoFullName string, number int) *github.PullRequest {
	owner, repo := getOwnerRepo(repoFullName)
	pr, _, _ := client.PullRequests.Get(ctx, owner, repo, number)
	return pr
}

func getIssueStatus(issue *github.Issue) string {
	result := ""
	if *issue.State == "closed" {
		result = "closed"
	}
	return result
}

func getPullRequestStatus(pr *github.PullRequest) string {
	result := ""
	if *pr.Merged {
		result = "merged"
	} else if *pr.State == "closed" {
		result = "closed"
	}
	return result
}

func getOwnerRepo(repoFullName string) (string, string) {
	s := strings.Split(repoFullName, "/")
	owner := s[0]
	repo := s[1]
	return owner, repo
}

// All returns all lines which are formatted and sorted
func (f *Format) All(lines Lines) string {
	var result, prevRepoName, currentRepoName string

	sort.Sort(lines)

	for _, line := range lines {
		currentRepoName = line.repoName

		if currentRepoName != prevRepoName {
			prevRepoName = currentRepoName
			result += fmt.Sprintf("\n#### %s\n\n", currentRepoName)
		}

		result += fmt.Sprintf("%s\n", formatLine(line))
	}

	return result
}

// Lines has sort.Interface
type Lines []Line

func (l Lines) Len() int {
	return len(l)
}

func (l Lines) Swap(i, j int) {
	l[i], l[j] = l[j], l[i]
}

func (l Lines) Less(i, j int) bool {
	return l[i].url < l[j].url
}

func formatLine(line Line) string {
	return fmt.Sprintf("* [%s](%s) by @[%s](https://github.com/%s) **%s!**",
		line.title, line.url, line.user, line.user, line.status)
}
