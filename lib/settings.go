package lib

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"strconv"
	"strings"

	// Import ./config/*
	_ "github.com/masutaka/github-nippou/v4/statik"

	"github.com/google/go-github/v56/github"
	"github.com/rakyll/statik/fs"
	"golang.org/x/oauth2"
	"gopkg.in/yaml.v3"
)

// Settings has configure
type Settings struct {
	Format struct {
		Subject string
		Line    string
	}
	Dictionary struct {
		Status struct {
			Merged string
			Closed string
		}
	}
	URL string
}

// Init initializes Settings
func (s *Settings) Init(gistID string, accessToken string) error {
	var content string
	var err error

	if gistID != "" {
		ctx := context.Background()
		client := getClient(ctx, accessToken)
		gist, _, err := client.Gists.Get(ctx, gistID)
		if err != nil {
			return err
		}

		content = *gist.Files["settings.yml"].Content
		s.URL = *gist.HTMLURL
	} else {
		content, err = getDefaultSettingsYml()
		if err != nil {
			return err
		}
		s.URL = getDefaultSettingsURL()
	}

	return yaml.Unmarshal([]byte(content), s)
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

func getParallelNum() (int, error) {
	if os.Getenv("GITHUB_NIPPOU_THREAD_NUM") != "" {
		return strconv.Atoi(os.Getenv("GITHUB_NIPPOU_THREAD_NUM"))
	}

	output, _ := exec.Command("git", "config", "github-nippou.thread-num").Output()

	if len(output) >= 1 {
		return strconv.Atoi(strings.TrimRight(string(output), "\n"))
	}

	return 5, nil
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
	statikFS, err := fs.New()
	if err != nil {
		return "", err
	}

	file, err := statikFS.Open("/settings.yml")
	if err != nil {
		return "", err
	}

	defer file.Close()

	yml, err := ioutil.ReadAll(file)
	if err != nil {
		return "", err
	}

	return string(yml), nil
}
