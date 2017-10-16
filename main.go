package main

//go:generate go-bindata -nocompress -pkg lib -o lib/bindata.go config

import (
	"fmt"
	"os"

	"github.com/masutaka/github-nippou/cmd"
)

func main() {
	if err := cmd.RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
