package lib_test

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/google/go-github/v92/github"
	"github.com/masutaka/github-nippou/v4/lib"
)

func TestInit(t *testing.T) {
	t.Skip("This test is pending.")
}

func TestGetUser(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_USER", "taro")
	defer os.Unsetenv("GITHUB_NIPPOU_USER")

	actual, _ := lib.GetUser(context.Background(), nil)
	const expected = "taro"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetUserFromAPI(t *testing.T) {
	isolateGitConfig(t)
	client := stubAPI(t, http.StatusOK, `{"login": "taro"}`)

	actual, err := lib.GetUser(context.Background(), client)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	const expected = "taro"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetUserWhenAPIFails(t *testing.T) {
	isolateGitConfig(t)
	client := stubAPI(t, http.StatusUnauthorized, `{"message": "Bad credentials"}`)

	if _, err := lib.GetUser(context.Background(), client); err == nil {
		t.Fatal("expected an error but got nil")
	}
}

func TestGetAccessToken(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_ACCESS_TOKEN", "1234abcd")
	defer os.Unsetenv("GITHUB_NIPPOU_ACCESS_TOKEN")

	actual, _ := lib.GetAccessToken()
	const expected = "1234abcd"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetAccessTokenFromGh(t *testing.T) {
	isolateGitConfig(t)
	stubGh(t, `[ "$*" = "auth token --hostname github.com" ] && echo gho_1234abcd`)

	actual, err := lib.GetAccessToken()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	const expected = "gho_1234abcd"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetAccessTokenWhenGhFails(t *testing.T) {
	isolateGitConfig(t)
	stubGh(t, `echo '{"message": "Bad credentials"}'; exit 1`)

	if _, err := lib.GetAccessToken(); err == nil {
		t.Fatal("expected an error but got nil")
	}
}

func TestGetAccessTokenWithoutGhLogin(t *testing.T) {
	isolateGitConfig(t)
	stubGh(t, "exit 1")

	_, err := lib.GetAccessToken()
	if err == nil {
		t.Fatal("expected an error but got nil")
	}
	const expected = "gh auth login"
	if !strings.Contains(err.Error(), expected) {
		t.Errorf("expected error to contain %q but got %q", expected, err.Error())
	}
}

// isolateGitConfig makes git config return nothing for github-nippou.*
func isolateGitConfig(t *testing.T) {
	t.Helper()
	t.Setenv("GITHUB_NIPPOU_USER", "")
	t.Setenv("GITHUB_NIPPOU_ACCESS_TOKEN", "")
	t.Setenv("GIT_CONFIG_GLOBAL", os.DevNull)
	t.Setenv("GIT_CONFIG_NOSYSTEM", "1")
	// Leave this repository so that its local config is not read
	t.Chdir(t.TempDir())
}

// stubGh puts a fake gh command running script at the front of PATH
func stubGh(t *testing.T, script string) {
	t.Helper()
	dir := t.TempDir()
	path := filepath.Join(dir, "gh")
	if err := os.WriteFile(path, []byte("#!/bin/sh\n"+script+"\n"), 0o755); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", dir+string(os.PathListSeparator)+os.Getenv("PATH"))
}

// stubAPI returns a client whose GET /user responds with status and body
func stubAPI(t *testing.T, status int, body string) *github.Client {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/user" {
			http.NotFound(w, r)
			return
		}
		w.WriteHeader(status)
		io.WriteString(w, body)
	}))
	t.Cleanup(server.Close)

	url := server.URL + "/"
	client, err := github.NewClient(github.WithURLs(&url, &url))
	if err != nil {
		t.Fatal(err)
	}
	return client
}

func TestGetGistID(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_SETTINGS_GIST_ID", "0123456789")
	defer os.Unsetenv("GITHUB_NIPPOU_SETTINGS_GIST_ID")

	actual := lib.GetGistID()
	const expected = "0123456789"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetParallelNum(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_THREAD_NUM", "10")
	defer os.Unsetenv("GITHUB_NIPPOU_THREAD_NUM")

	actual, _ := lib.GetParallelNum()
	const expected = 10
	if actual != expected {
		t.Errorf("expected %d but got %d", expected, actual)
	}
}

func TestGetDefaultSettingsURL(t *testing.T) {
	actual := lib.GetDefaultSettingsURL()
	const expected = "https://github.com/masutaka/github-nippou/blob/v" + lib.Version + "/config/settings.yml"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetDefaultSettingsYml(t *testing.T) {
	t.Skip("This test is pending.")
}
