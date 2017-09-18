package lib

import (
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

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

func getGistID() string {
	if os.Getenv("GITHUB_NIPPOU_SETTINGS_GIST_ID") != "" {
		return os.Getenv("GITHUB_NIPPOU_SETTINGS_GIST_ID")
	}

	output, _ := exec.Command("git", "config", "github-nippou.settings-gist-id").Output()

	if len(output) == 1 {
		return ""
	}

	return strings.TrimRight(string(output), "\n")
}

func getClient(ctx context.Context, accessToken string) *github.Client {
	sts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: accessToken},
	)
	return github.NewClient(oauth2.NewClient(ctx, sts))
}

func getClientScopes(ctx context.Context, client *github.Client) ([]string, error) {
	_, response, err := client.Users.Get(ctx, "")
	return strings.Split(response.Header.Get("X-OAuth-Scopes"), ", "), err
}

func createGist(ctx context.Context, client *github.Client) (*github.Gist, *github.Response, error) {
	content, err := getDefaultSettingsYml()
	if err != nil {
		return nil, nil, err
	}

	gistFiles := make(map[github.GistFilename]github.GistFile, 1)
	gistFiles["settings.yml"] = github.GistFile{
		Content: github.String(content),
	}

	gist := &github.Gist{
		Description: github.String("github-nippou settings"),
		Public:      github.Bool(true),
		Files:       gistFiles,
	}

	return client.Gists.Create(ctx, gist)
}

func getDefaultSettingsURL() string {
	return fmt.Sprintf("https://github.com/masutaka/github-nippou/blob/v%s/config/settings.yml", Version)
}

func getDefaultSettingsYml() (string, error) {
	yml, err := Asset("config/settings.yml")
	return string(yml), err
}
