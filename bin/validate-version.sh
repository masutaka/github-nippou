#!/bin/sh -eu

a=lib/github/nippou/version.rb
b=Dockerfile

if [ $(fgrep VERSION $a | awk '{print $3}' | tr -d "'") != $(fgrep 'VERSION=' $b | awk -F = '{print $2}') ]; then
  echo "The versions of $a and $b are different." >&2
  exit 1
fi
