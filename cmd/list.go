package cmd

import (
	"os"
	"time"

	"github.com/masutaka/github-nippou/lib"
	"github.com/spf13/cobra"
)

var sinceDate string
var untilDate string

func init() {
	RootCmd.AddCommand(listCmd)

	nowDate := time.Now().Format("20060102")
	sinceDate = nowDate
	untilDate = nowDate

	listCmd.PersistentFlags().StringVarP(&sinceDate, "since-date", "s", sinceDate, "Retrieves GitHub user_events since the date")
	listCmd.PersistentFlags().StringVarP(&untilDate, "until-date", "u", untilDate, "Retrieves GitHub user_events until the date")
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "Print today's your GitHub action",
	Run: func(cmd *cobra.Command, args []string) {
		if err := lib.List(sinceDate, untilDate); err != nil {
			os.Exit(1)
		}
	},
}
