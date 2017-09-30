package cmd

import (
	"fmt"

	"github.com/masutaka/github-nippou/lib"
	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("%s\n", lib.Version)
	},
}

func init() {
	RootCmd.AddCommand(versionCmd)
}
