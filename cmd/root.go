package cmd

import (
	"fmt"
	"os"
	"time"

	"github.com/masutaka/github-nippou/lib"
	"github.com/spf13/cobra"
)

var sinceDate string
var untilDate string
var debug bool

// RootCmd defines a root command
var RootCmd = &cobra.Command{
	Use:   "github-nippou",
	Short: "Print today's your GitHub activity for issues and pull requests",
	Run: func(cmd *cobra.Command, args []string) {
		list, err := lib.NewListFromCLI(sinceDate, untilDate, debug)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		lines, err := list.Collect()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		fmt.Println(lines)
	},
}

func init() {
	nowDate := time.Now().Format("20060102")
	sinceDate = nowDate
	untilDate = nowDate

	RootCmd.PersistentFlags().StringVarP(&sinceDate, "since-date", "s", sinceDate, "Retrieves GitHub user_events since the date")
	RootCmd.PersistentFlags().StringVarP(&untilDate, "until-date", "u", untilDate, "Retrieves GitHub user_events until the date")
	RootCmd.PersistentFlags().BoolVarP(&debug, "debug", "d", false, "Debug mode")
}
