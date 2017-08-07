#!/bin/sh -eu

a=lib/github/nippou/version.rb
b=Dockerfile

version_of_file_a() {
  fgrep VERSION $1 | awk '{print $3}' | tr -d "'"
}

version_of_file_b() {
  fgrep 'VERSION=' $1 | awk -F = '{print $2}'
}

if [ $(version_of_file_a $a) != $(version_of_file_b $b) ]; then
  echo "The versions of $a and $b are different." >&2
  exit 1
fi
