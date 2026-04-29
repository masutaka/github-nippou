package lib_test

import (
	"context"
	"testing"

	"github.com/google/go-github/v80/github"
	"github.com/masutaka/github-nippou/v4/lib"
)

func TestFormatAll(t *testing.T) {
	issue := github.Issue{
		State:   github.Ptr("closed"),
		Title:   github.Ptr("イベントを取得できないことがある"),
		User:    &github.User{Login: github.Ptr("masutaka")},
		HTMLURL: github.Ptr("https://github.com/masutaka/github-nippou/issues/1"),
	}
	pr := github.PullRequest{
		State:   github.Ptr("closed"),
		Title:   github.Ptr("Bundle Update on 2015-10-04"),
		User:    &github.User{Login: github.Ptr("deppbot")},
		HTMLURL: github.Ptr("https://github.com/masutaka/github-nippou/pull/31"),
		Merged:  github.Ptr(true),
	}
	discussion := github.Discussion{
		State:   github.Ptr("closed"),
		Title:   github.Ptr("ロードマップ募集"),
		User:    &github.User{Login: github.Ptr("masutaka")},
		HTMLURL: github.Ptr("https://github.com/masutaka/github-nippou/discussions/2"),
	}
	lines := lib.Lines{
		lib.NewLineByIssue("masutaka/github-nippou", issue),
		lib.NewLineByPullRequest("masutaka/github-nippou", pr),
		lib.NewLineByDiscussion("masutaka/github-nippou", discussion),
	}
	settings := lib.Settings{}
	settings.Init("", "")

	ctx := context.Background()
	f := lib.NewFormat(ctx, nil, settings, false)

	result, err := f.All(lines)
	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}

	expected := `
### masutaka/github-nippou

* [ロードマップ募集](https://github.com/masutaka/github-nippou/discussions/2) by @[masutaka](https://github.com/masutaka) **closed!**
* [イベントを取得できないことがある](https://github.com/masutaka/github-nippou/issues/1) by @[masutaka](https://github.com/masutaka) **closed!**
* [Bundle Update on 2015-10-04](https://github.com/masutaka/github-nippou/pull/31) by @[deppbot](https://github.com/deppbot) **merged!**
`

	if result != expected {
		t.Errorf("unexpected result: got %q, want %q", result, expected)
	}
}
