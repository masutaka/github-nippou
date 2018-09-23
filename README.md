# github-nippou

[![Travis Status](https://img.shields.io/travis/masutaka/github-nippou.svg?logo=travis&style=flat-square)][travisci]
[![License](https://img.shields.io/github/license/masutaka/github-nippou.svg?style=flat-square)][license]
[![GoDoc](https://godoc.org/github.com/masutaka/github-nippou?status.svg)][godoc]

[travisci]: https://travis-ci.org/masutaka/github-nippou
[license]: https://github.com/masutaka/github-nippou/blob/master/LICENSE.txt
[godoc]: https://godoc.org/github.com/masutaka/github-nippou

Print today's your GitHub action.

This is a helpful tool when you write a daily report in reference to
GitHub. Nippou is a japanese word which means a daily report.

## Installation

Grab the latest binary from the [releases](https://github.com/masutaka/github-nippou/releases) page.

On macOS you can install or upgrade to the latest released version with Homebrew:

```
$ brew install masutaka/github-nippou/github-nippou
$ brew upgrade github-nippou
```

If you're interested in hacking on `github-nippou`, you can install via `go get`:

```
$ go get -u github.com/masutaka/github-nippou
```

Also you can use make command, it's easy to build `github-nippou`:

```
$ make deps
$ make
$ ./github-nippou
```

## Setup

    $ github-nippou init

The initialization will be update your `~/.gitconfig`.

1. Add `github-nippou.user`
2. Add `github-nippou.token`
3. Create Gist, and add `github-nippou.settings-gist-id` for customizing output format (optional)

## Usage

```
$ github-nippou help
Print today's your GitHub action

Usage:
  github-nippou [flags]
  github-nippou [command]

Available Commands:
  help          Help about any command
  init          Initialize github-nippou settings
  list          Print today's your GitHub action
  open-settings Open settings url with web browser
  version       Print version

Flags:
  -d, --debug               Debug mode
  -h, --help                help for github-nippou
  -s, --since-date string   Retrieves GitHub user_events since the date (default "20171007")
  -u, --until-date string   Retrieves GitHub user_events until the date (default "20171007")

Use "github-nippou [command] --help" for more information about a command.
```

You can get your GitHub Nippou on today.

```
$ github-nippou

### masutaka/github-nippou

* [v3.0.0](https://github.com/masutaka/github-nippou/issues/59) by @[masutaka](https://github.com/masutaka)
* [Enable to inject settings_gist_id instead of the settings](https://github.com/masutaka/github-nippou/pull/63) by @[masutaka](https://github.com/masutaka) **merged!**
* [Add y/n prompt to sub command \`init\`](https://github.com/masutaka/github-nippou/pull/64) by @[masutaka](https://github.com/masutaka) **merged!**
* [Add sub command \`open-settings\`](https://github.com/masutaka/github-nippou/pull/65) by @[masutaka](https://github.com/masutaka) **merged!**
* [Dockerize](https://github.com/masutaka/github-nippou/pull/66) by @[masutaka](https://github.com/masutaka) **merged!**
```

## Contributing

1. Fork it ( https://github.com/masutaka/github-nippou/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Maintenance

It's possible to release to GitHub using `make` command.

```
$ git checkout master
$ git pull
$ make dist
$ make release
```

## External article

In Japanese

[github-nippou - GitHubから日報を作成 MOONGIFT](http://www.moongift.jp/2016/06/github-nippou-github%E3%81%8B%E3%82%89%E6%97%A5%E5%A0%B1%E3%82%92%E4%BD%9C%E6%88%90/)
