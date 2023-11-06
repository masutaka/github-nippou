package cmd

import (
	"fmt"
	"os"

	"github.com/masutaka/github-nippou/v4/lib"
	"github.com/spf13/cobra"
)

var openSettingsCmd = &cobra.Command{
	Use:   "open-settings",
	Short: "Open settings url with web browser",
	Run: func(cmd *cobra.Command, args []string) {
		if err := lib.OpenSettings(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	},
}

func init() {
	RootCmd.AddCommand(openSettingsCmd)
}
