package lib_test

import (
	"os"
	"testing"

	"github.com/masutaka/github-nippou/lib"
)

func TestInit(t *testing.T) {
	t.Skip("This test is pending.")
}

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

func TestGetGistID(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_SETTINGS_GIST_ID", "0123456789")

	actual := lib.GetGistID()
	const expected = "0123456789"
	if actual != expected {
		t.Errorf("expected %s but got %s", expected, actual)
	}

	os.Setenv("GITHUB_NIPPOU_SETTINGS_GIST_ID", "")
}

func TestGetParallelNum(t *testing.T) {
	os.Setenv("GITHUB_NIPPOU_THREAD_NUM", "10")

	actual, _ := lib.GetParallelNum()
	const expected = 10
	if actual != expected {
		t.Errorf("expected %d but got %d", expected, actual)
	}

	os.Setenv("GITHUB_NIPPOU_THREAD_NUM", "")
}

func TestGetDefaultSettingsURL(t *testing.T) {
	actual := lib.GetDefaultSettingsURL()
	const expected = "https://github.com/masutaka/github-nippou/blob/v" + lib.Version + "/config/settings.yml"
	if actual != expected {
		t.Errorf("expected %d but got %d", expected, actual)
	}
}

func TestGetDefaultSettingsYml(t *testing.T) {
	t.Skip("This test is pending.")
}
