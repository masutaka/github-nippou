#!/bin/sh -eu

a=lib/github/nippou/version.rb
b=Dockerfile

version_of_file_a() {
  fgrep VERSION $a | awk '{print $3}' | tr -d "'"
}

version_of_file_b() {
  fgrep 'VERSION=' $b | awk -F = '{print $2}'
}

if [ $(version_of_file_a) != $(version_of_file_b) ]; then
  echo "The versions of $a and $b are different." >&2
  exit 1
fi
