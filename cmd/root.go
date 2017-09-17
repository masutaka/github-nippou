package cmd

import (
	"github.com/spf13/cobra"
)

// RootCmd defines a root command
var RootCmd = &cobra.Command{
	Use:   "github-nippou",
	Short: "Print today's your GitHub action.",
	Long: `This is a helpful tool when you write a daily report in reference to
GitHub. nippou is a japanese word which means a daily report.`,
	Run: func(cmd *cobra.Command, args []string) {
	},
}
