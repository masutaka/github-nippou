package lib

import (
	"bytes"
	"context"
	"fmt"
	"regexp"
	"sort"
	"strings"
	"text/template"

	"github.com/google/go-github/github"
)

// Format is Formatter
type Format struct {
	ctx      context.Context
	client   *github.Client
	settings Settings
	debug    bool
}

// NewFormat is an initializer
func NewFormat(ctx context.Context, client *github.Client, settings Settings, debug bool) *Format {
	return &Format{ctx: ctx, client: client, settings: settings, debug: debug}
}

// Line is line infomation
type Line struct {
	title    string
	repoName string
	url      string
	user     string
	status   string
}

// NewLineByIssue is an initializer by Issue
func NewLineByIssue(repoName string, issue github.Issue) Line {
	return Line{
		title:    *issue.Title,
		repoName: repoName,
		url:      *issue.HTMLURL,
		user:     *issue.User.Login,
		status:   getIssueStatus(issue),
	}
}

// NewLineByPullRequest is an initializer by PR
func NewLineByPullRequest(repoName string, pr github.PullRequest) Line {
	return Line{
		title:    *pr.Title,
		repoName: repoName,
		url:      *pr.HTMLURL,
		user:     *pr.User.Login,
		status:   getPullRequestStatus(pr),
	}
}

// Line returns Issue/PR info retrieving from GitHub
func (f *Format) Line(event *github.Event, i int) Line {
	payload := event.Payload()
	var line Line

	switch *event.Type {
	case "IssuesEvent":
		e := payload.(*github.IssuesEvent)
		issue := getIssue(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)

		if issue != nil {
			if issue.PullRequestLinks == nil {
				line = NewLineByIssue(*event.Repo.Name, *issue)
			} else {
				pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)
				line = NewLineByPullRequest(*event.Repo.Name, *pr)
			}
		} else {
			line = NewLineByIssue(*event.Repo.Name, *e.Issue)
		}
	case "IssueCommentEvent":
		e := payload.(*github.IssueCommentEvent)
		issue := getIssue(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)

		if issue != nil {
			if issue.PullRequestLinks == nil {
				line = NewLineByIssue(*event.Repo.Name, *issue)
			} else {
				pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.Issue.Number)
				line = NewLineByPullRequest(*event.Repo.Name, *pr)
			}
		} else {
			line = NewLineByIssue(*event.Repo.Name, *e.Issue)
		}
	case "PullRequestEvent":
		e := payload.(*github.PullRequestEvent)
		pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, e.GetNumber())
		if pr != nil {
			line = NewLineByPullRequest(*event.Repo.Name, *pr)
		} else {
			line = NewLineByPullRequest(*event.Repo.Name, *e.PullRequest)
		}
	case "PullRequestReviewCommentEvent":
		e := payload.(*github.PullRequestReviewCommentEvent)
		pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.PullRequest.Number)
		if pr != nil {
			line = NewLineByPullRequest(*event.Repo.Name, *pr)
		} else {
			line = NewLineByPullRequest(*event.Repo.Name, *e.PullRequest)
		}
	case "PullRequestReviewEvent":
		e := payload.(*github.PullRequestReviewEvent)
		pr := getPullRequest(f.ctx, f.client, *event.Repo.Name, *e.PullRequest.Number)
		if pr != nil {
			line = NewLineByPullRequest(*event.Repo.Name, *pr)
		} else {
			line = NewLineByPullRequest(*event.Repo.Name, *e.PullRequest)
		}
	}

	if f.debug {
		fmt.Printf("[Debug] %2d %s: %v\n", i, *event.Type, line)
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

func getIssueStatus(issue github.Issue) string {
	result := ""
	if *issue.State == "closed" {
		result = "closed"
	}
	return result
}

func getPullRequestStatus(pr github.PullRequest) string {
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
func (f *Format) All(lines Lines) (string, error) {
	var result, prevRepoName, currentRepoName string

	sort.Sort(lines)

	for _, line := range lines {
		currentRepoName = line.repoName

		if currentRepoName != prevRepoName {
			prevRepoName = currentRepoName
			result += fmt.Sprintf("\n%s\n\n", formatSubject(f.settings, currentRepoName))
		}

		result += fmt.Sprintf("%s\n", formatLine(f.settings, line))
	}

	return result, nil
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

func formatSubject(settings Settings, repoName string) string {
	formatSubject := convertNamedParameters(settings.Format.Subject)

	m := map[string]interface{}{"subject": repoName}
	t := template.Must(template.New("").Parse(formatSubject))

	var rendered bytes.Buffer
	t.Execute(&rendered, m)

	return rendered.String()
}

func formatLine(settings Settings, line Line) string {
	formatLine := convertNamedParameters(settings.Format.Line)

	m := map[string]interface{}{
		"title":  line.title,
		"url":    line.url,
		"user":   line.user,
		"status": formatStatus(settings, line.status),
	}
	t := template.Must(template.New("").Parse(formatLine))

	var rendered bytes.Buffer
	t.Execute(&rendered, m)

	return strings.TrimSpace(rendered.String())
}

func formatStatus(settings Settings, status string) string {
	switch status {
	case "merged":
		return settings.Dictionary.Status.Merged
	case "closed":
		return settings.Dictionary.Status.Closed
	default:
		return ""
	}
}

// "%{hoge}" => "{{.hoge}}"
func convertNamedParameters(str string) string {
	re := regexp.MustCompile("%{([^}]+)}")
	return re.ReplaceAllString(str, "{{.$1}}")
}
