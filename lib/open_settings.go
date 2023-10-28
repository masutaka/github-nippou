package lib

import (
	"fmt"

	"github.com/skratchdot/open-golang/open"
)

// OpenSettings opens settings url with web browser
func OpenSettings() error {
	var settings Settings

	if err := settings.Init(getGistID(), ""); err != nil {
		return nil
	}

	fmt.Printf("Open %s\n", settings.URL)
	return open.Run(settings.URL)
}
