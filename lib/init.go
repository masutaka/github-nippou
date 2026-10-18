package lib

import (
	"context"
	"errors"
	"fmt"
	"os/exec"
	"strings"
	"time"

	"github.com/google/go-github/v92/github"
)

// Init initializes github-nippou settings
func Init() error {
	fmt.Print("** github-nippou Initialization **\n")

	ctx := context.Background()

	client, err := checkAccessToken(ctx)
	if err != nil {
		return err
	}

	time.Sleep(500 * time.Millisecond)

	return createAndSetGist(ctx, client)
}

func checkAccessToken(ctx context.Context) (*github.Client, error) {
	fmt.Print(`
== [Step: 1/2] GitHub access token ==

github-nippou uses the token of GitHub CLI (` + "`gh auth token`" + `) by default.

`)

	accessToken, err := getAccessToken()
	if err != nil {
		return nil, err
	}

	fmt.Print("Found the access token.\n")

	client, err := getClient(ctx, accessToken)
	if err != nil {
		return nil, err
	}

	scopes, err := getClientScopes(ctx, client)
	if err != nil {
		return nil, err
	}

	if !isValidScopes(scopes) {
		return nil, errors.New(`!!!! ` + "`repo`" + ` and ` + "`gist`" + ` scopes are required. !!!!

If you use the token of GitHub CLI, add these scopes with
the following command.

    $ gh auth refresh -s repo,gist

If you use personal access token (deprecated), add these scopes
to it, visit https://github.com/settings/tokens

`)

	}

	return client, nil
}

func isValidScopes(scopes []string) bool {
	var found1, found2 bool

	for _, v := range scopes {
		if v == "repo" {
			found1 = true
		}

		if v == "gist" {
			found2 = true
		}
	}

	return found1 && found2
}

func createAndSetGist(ctx context.Context, client *github.Client) error {
	fmt.Print(`
== [Step: 2/2] Gist (optional) ==

`)

	var msg string

	if len(getGistID()) >= 1 {
		msg = "Already initialized."
	} else {
		var answer string = "N"

		fmt.Printf(`1. Create a gist with the content of %s
2. The following command will be executed

    $ git config --global github-nippou.settings-gist-id <created gist id>

`, getDefaultSettingsURL())

		fmt.Print("Are you sure? [y/N] ")
		fmt.Scanln(&answer)

		if strings.ToUpper(answer[0:1]) == "N" {
			return nil
		}

		gist, _, err := createGist(ctx, client)
		if err != nil {
			return err
		}

		cmd := exec.Command("git", "config", "--global", "github-nippou.settings-gist-id", *gist.ID)
		if err := cmd.Run(); err != nil {
			return err
		}

		msg = "Thanks!"
	}

	fmt.Printf(`%s You can get it with the following command.

    $ git config --global github-nippou.settings-gist-id

And you can easily open the gist URL with web browser.

    $ github-nippou open-settings

`, msg)

	return nil
}
