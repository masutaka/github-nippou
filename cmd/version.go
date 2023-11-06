package cmd

import (
	"fmt"
	"runtime"

	"github.com/masutaka/github-nippou/v4/lib"
	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("%s (built with %s)\n", lib.Version, runtime.Version())
	},
}

func init() {
	RootCmd.AddCommand(versionCmd)
}
