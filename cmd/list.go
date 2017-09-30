package cmd

import (
	"github.com/spf13/cobra"
)

var listCmd = &cobra.Command{
	Use:   "list",
	Short: RootCmd.Short,
	Run:   RootCmd.Run,
}

func init() {
	RootCmd.AddCommand(listCmd)
}
