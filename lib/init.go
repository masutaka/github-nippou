package lib

import (
	"context"
	"errors"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

// Init initializes github-nippou settings
func Init() error {
	fmt.Print("** github-nippou Initialization **\n")

	if err := setUser(); err != nil {
		return err
	}

	time.Sleep(500 * time.Millisecond)
	ctx := context.Background()

	if err := setAccessToken(ctx); err != nil {
		return err
	}

	time.Sleep(500 * time.Millisecond)

	return createAndSetGist(ctx)
}

func setUser() error {
	fmt.Print(`
== [Step: 1/3] GitHub user ==

`)

	var msg string

	if _, err := getUser(); err == nil {
		msg = "Already initialized."
	} else {
		var user string
		var answer string = "Y"

		fmt.Print("What's your GitHub account? ")
		fmt.Scanln(&user)

		if len(user) >= 1 {
			fmt.Printf(`
The following command will be executed.

    $ git config --global github-nippou.user %s

`, user)

			fmt.Print("Are you sure? [Y/n] ")
			fmt.Scanln(&answer)

			if strings.ToUpper(answer[0:1]) != "Y" {
				return errors.New("Canceled")
			}

			cmd := exec.Command("git", "config", "--global", "github-nippou.user", user)
			if err := cmd.Run(); err != nil {
				return err
			}

			msg = "Thanks!"
		}
	}

	fmt.Printf(`%s You can get it with the following command.

    $ git config --global github-nippou.user

`, msg)

	return nil
}

func setAccessToken(ctx context.Context) error {
	fmt.Print(`
== [Step: 2/3] GitHub personal access token ==

To get new token with ` + "`repo`" + ` and ` + "`gist`" + ` scope, visit
https://github.com/settings/tokens/new

`)

	var msg string

	accessToken, err := getAccessToken()

	if err == nil {
		msg = "Already initialized."
	} else {
		var answer string = "Y"

		fmt.Print("What's your GitHub personal access token? ")
		fmt.Scanln(&accessToken)

		if len(accessToken) >= 1 {
			fmt.Printf(`
The following command will be executed.

    $ git config --global github-nippou.token %s

`, accessToken)

			fmt.Print("Are you sure? [Y/n] ")
			fmt.Scanln(&answer)

			if strings.ToUpper(answer[0:1]) != "Y" {
				return errors.New("Canceled")
			}

			cmd := exec.Command("git", "config", "--global", "github-nippou.token", accessToken)
			if err := cmd.Run(); err != nil {
				return err
			}

			msg = "Thanks!"
		}
	}

	fmt.Printf(`%s You can get it with the following command.

    $ git config --global github-nippou.token

`, msg)

	scopes, err := getClientScopes(ctx, getClient(ctx, accessToken))
	if err != nil {
		return err
	}

	if !isValidScopes(scopes) {
		return errors.New(`!!!! ` + "`repo`" + ` and ` + "`gist`" + ` scopes are required. !!!!

You need personal access token which has ` + "`repo`" + ` and ` + "`gist`" + `
scopes. Please add these scopes to your personal access
token, visit https://github.com/settings/tokens

`)

	}

	return nil
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

func createAndSetGist(ctx context.Context) error {
	fmt.Print(`
== [Step: 3/3] Gist (optional) ==

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

		accessToken, err := getAccessToken()
		if err != nil {
			return err
		}

		gist, _, err := createGist(ctx, getClient(ctx, accessToken))
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
