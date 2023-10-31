package lib

import (
	"fmt"

	"github.com/skratchdot/open-golang/open"
)

// OpenSettings opens settings url with web browser
func OpenSettings() error {
	var settings Settings

	accessToken, err := getAccessToken()
	if err != nil {
		return err
	}

	if err := settings.Init(getGistID(), accessToken); err != nil {
		return nil
	}

	fmt.Printf("Open %s\n", settings.URL)
	return open.Run(settings.URL)
}
