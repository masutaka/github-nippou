package cmd

import (
	"fmt"
	"os"

	"github.com/masutaka/github-nippou/lib"
	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(openSettingsCmd)
}

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
