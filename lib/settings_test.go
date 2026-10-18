package lib_test

import (
	"bytes"
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
	captureWarning(t)

	actual, _ := lib.GetUser(context.Background(), nil)
	const expected = "taro"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetUserWarnsEnvDeprecation(t *testing.T) {
	isolateGitConfig(t)
	t.Setenv("GITHUB_NIPPOU_USER", "taro")
	warning := captureWarning(t)

	if _, err := lib.GetUser(context.Background(), nil); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	const expected = "GITHUB_NIPPOU_USER is deprecated"
	if !strings.Contains(warning.String(), expected) {
		t.Errorf("expected warning to contain %q but got %q", expected, warning.String())
	}
}

func TestGetUserWarnsGitConfigDeprecation(t *testing.T) {
	isolateGitConfig(t)
	setGitConfig(t, "[github-nippou]\n\tuser = taro\n")
	warning := captureWarning(t)

	actual, err := lib.GetUser(context.Background(), nil)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if actual != "taro" {
		t.Errorf("expected %s but got %s", "taro", actual)
	}
	const expected = "github-nippou.user is deprecated"
	if !strings.Contains(warning.String(), expected) {
		t.Errorf("expected warning to contain %q but got %q", expected, warning.String())
	}
}

func TestGetUserFromAPI(t *testing.T) {
	isolateGitConfig(t)
	client := stubAPI(t, http.StatusOK, `{"login": "taro"}`)
	warning := captureWarning(t)

	actual, err := lib.GetUser(context.Background(), client)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	const expected = "taro"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
	if warning.Len() != 0 {
		t.Errorf("expected no warning but got %q", warning.String())
	}
}

func TestGetUserWhenUnauthorized(t *testing.T) {
	isolateGitConfig(t)
	client := stubAPI(t, http.StatusUnauthorized, `{"message": "Bad credentials"}`)

	_, err := lib.GetUser(context.Background(), client)
	if err == nil {
		t.Fatal("expected an error but got nil")
	}
	const expected = "Please check your access token"
	if !strings.Contains(err.Error(), expected) {
		t.Errorf("expected error to contain %q but got %q", expected, err.Error())
	}
}

func TestGetUserWhenAPIIsDown(t *testing.T) {
	isolateGitConfig(t)
	client := stubAPI(t, http.StatusServiceUnavailable, `{"message": "Service Unavailable"}`)

	_, err := lib.GetUser(context.Background(), client)
	if err == nil {
		t.Fatal("expected an error but got nil")
	}
	const unexpected = "Please check your access token"
	if strings.Contains(err.Error(), unexpected) {
		t.Errorf("expected error not to contain %q but got %q", unexpected, err.Error())
	}
}

func TestGetAccessToken(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_ACCESS_TOKEN", "1234abcd")
	defer os.Unsetenv("GITHUB_NIPPOU_ACCESS_TOKEN")
	captureWarning(t)

	actual, _ := lib.GetAccessToken()
	const expected = "1234abcd"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
}

func TestGetAccessTokenWarnsEnvDeprecation(t *testing.T) {
	isolateGitConfig(t)
	t.Setenv("GITHUB_NIPPOU_ACCESS_TOKEN", "1234abcd")
	warning := captureWarning(t)

	if _, err := lib.GetAccessToken(); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	const expected = "warning: GITHUB_NIPPOU_ACCESS_TOKEN is deprecated and will be removed in v5.0.0\n" +
		"  Run `gh auth login` and unset it. In CI, install GitHub CLI and pass the token via GH_TOKEN. See https://github.com/masutaka/github-nippou/issues/379\n"
	if warning.String() != expected {
		t.Errorf("expected warning %q but got %q", expected, warning.String())
	}
}

func TestGetAccessTokenWarnsGitConfigDeprecation(t *testing.T) {
	isolateGitConfig(t)
	setGitConfig(t, "[github-nippou]\n\ttoken = 1234abcd\n")
	warning := captureWarning(t)

	actual, err := lib.GetAccessToken()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if actual != "1234abcd" {
		t.Errorf("expected %s but got %s", "1234abcd", actual)
	}
	const expected = "github-nippou.token is deprecated"
	if !strings.Contains(warning.String(), expected) {
		t.Errorf("expected warning to contain %q but got %q", expected, warning.String())
	}
}

func TestGetAccessTokenFromGh(t *testing.T) {
	isolateGitConfig(t)
	stubGh(t, `[ "$*" = "auth token --hostname github.com" ] && echo gho_1234abcd`)
	warning := captureWarning(t)

	actual, err := lib.GetAccessToken()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	const expected = "gho_1234abcd"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}
	if warning.Len() != 0 {
		t.Errorf("expected no warning but got %q", warning.String())
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

// setGitConfig makes git config read content as the global config
func setGitConfig(t *testing.T, content string) {
	t.Helper()
	path := filepath.Join(t.TempDir(), "gitconfig")
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
	t.Setenv("GIT_CONFIG_GLOBAL", path)
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

// captureWarning returns a buffer that receives warnings instead of stderr
func captureWarning(t *testing.T) *bytes.Buffer {
	t.Helper()
	var buf bytes.Buffer
	original := *lib.WarningWriter
	*lib.WarningWriter = &buf
	t.Cleanup(func() { *lib.WarningWriter = original })
	return &buf
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

func TestIsColorTerminal(t *testing.T) {
	// /dev/null is a character device like a terminal
	device, err := os.Open(os.DevNull)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { device.Close() })

	file, err := os.Create(filepath.Join(t.TempDir(), "file"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { file.Close() })

	tests := []struct {
		name     string
		writer   io.Writer
		noColor  string
		term     string
		expected bool
	}{
		{"character device", device, "", "xterm-256color", true},
		{"character device with NO_COLOR", device, "1", "xterm-256color", false},
		{"character device with TERM=dumb", device, "", "dumb", false},
		{"regular file", file, "", "xterm-256color", false},
		{"buffer", &bytes.Buffer{}, "", "xterm-256color", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv("NO_COLOR", tt.noColor)
			t.Setenv("TERM", tt.term)
			if actual := lib.IsColorTerminal(tt.writer); actual != tt.expected {
				t.Errorf("expected %v but got %v", tt.expected, actual)
			}
		})
	}
}

func TestGetClientScopesWhenUnreachable(t *testing.T) {
	server := httptest.NewServer(http.NotFoundHandler())
	url := server.URL + "/"
	server.Close()
	client, err := github.NewClient(github.WithURLs(&url, &url))
	if err != nil {
		t.Fatal(err)
	}

	if _, err := lib.GetClientScopes(context.Background(), client); err == nil {
		t.Fatal("expected an error but got nil")
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
