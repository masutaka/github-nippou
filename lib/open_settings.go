package lib

import (
	"fmt"

	"github.com/skratchdot/open-golang/open"
)

// OpenSettings opens settings url with web browser
func OpenSettings() error {
	settingsURL := getDefaultSettingsURL()
	fmt.Printf("Open %s\n", settingsURL)
	return open.Run(settingsURL)
}
