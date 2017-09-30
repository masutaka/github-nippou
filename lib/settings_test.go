package lib_test

import (
	"os"
	"testing"

	"github.com/masutaka/github-nippou/lib"
)

func TestGetUser(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_USER", "taro")

	actual, _ := lib.GetUser()
	const expected = "taro"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}

	os.Setenv("GITHUB_NIPPOU_USER", "")
}

func TestGetAccessToken(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_ACCESS_TOKEN", "1234abcd")

	actual, _ := lib.GetAccessToken()
	const expected = "1234abcd"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}

	os.Setenv("GITHUB_NIPPOU_ACCESS_TOKEN", "")
}
