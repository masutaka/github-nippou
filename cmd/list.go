package cmd

import (
	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(listCmd)
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: RootCmd.Short,
	Run:   RootCmd.Run,
}
