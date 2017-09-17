package cmd

import (
	"fmt"

	"github.com/masutaka/github-nippou/lib"
	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(versionCmd)
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("%s\n", lib.Version)
	},
}
