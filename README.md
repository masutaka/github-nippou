# github-nippou

[![Test](https://github.com/masutaka/github-nippou/actions/workflows/test.yml/badge.svg)][Test]
[![Go Report Card](https://goreportcard.com/badge/github.com/masutaka/github-nippou/v4)][Go Report Card]
[![Go Reference](https://pkg.go.dev/badge/github.com/masutaka/github-nippou/v4.svg)][Go Reference]

[Test]: https://github.com/masutaka/github-nippou/actions/workflows/test.yml?query=branch%3Amain
[Go Report Card]: https://goreportcard.com/report/github.com/masutaka/github-nippou/v4
[Go Reference]: https://pkg.go.dev/github.com/masutaka/github-nippou/v4

Print today's your GitHub activity for issues and pull requests.

This is a helpful CLI when you write a daily report in reference to GitHub. Nippou is a japanese word which means a daily report.

A web version of this CLI is also available at https://github.com/MH4GF/github-nippou-web .

## Installation

Grab the latest binary from the [releases](https://github.com/masutaka/github-nippou/releases) page.

On macOS you can install or upgrade to the latest released version with Homebrew:

```
$ brew install masutaka/tap/github-nippou
$ brew upgrade github-nippou
```

If you're interested in hacking on `github-nippou`, you can install via `go install`:

```
$ go install github.com/masutaka/github-nippou/v4@latest
```

Also you can use make command, it's easy to build `github-nippou`:

```
$ make deps
$ make
$ ./github-nippou
```

## Setup

    $ github-nippou init

The initialization will be update your [Git global configuration file](https://git-scm.com/docs/git-config#Documentation/git-config.txt-XDGCONFIGHOMEgitconfig).

1. Add `github-nippou.user`
2. Add `github-nippou.token`
3. Create Gist, and add `github-nippou.settings-gist-id` for customizing output format (optional)

## Usage

```
$ github-nippou help
Print today's your GitHub activity for issues and pull requests

Usage:
  github-nippou [flags]
  github-nippou [command]

Available Commands:
  completion    Generate the autocompletion script for the specified shell
  help          Help about any command
  init          Initialize github-nippou settings
  list          Print today's your GitHub activity for issues and pull requests
  open-settings Open settings url with web browser
  version       Print version

Flags:
  -d, --debug               Debug mode
  -h, --help                help for github-nippou
  -s, --since-date string   Retrieves GitHub user_events since the date (default "20231028")
  -u, --until-date string   Retrieves GitHub user_events until the date (default "20231028")

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

## Optional: Customize Output Format

Customize the list output format as needed. Configurations are stored in a Gist.   
Running `github-nippou init` creates your Gist and adds its ID to `github-nippou.settings-gist-id`.

View the default configuration [here](./config/settings.yml).

### Available Properties

#### `format.subject`

| Property | Type | Description |
| --- | --- | --- |
| `subject` | `string` | Represents the repository name. |

#### `format.line`

| Property | Type | Description |
| --- | --- | --- |
| `user` | `string` | Displays the username of author of the issue or pull request. |
| `title` | `string` | Displays the title of the issue or pull request. |
| `url` | `string` | Displays the URL of the issue or pull request. |
| `status` | `string \| nil` | Displays the status, utilizing the format in `dictionary.status`. |

#### `format.dictionary.status`

| Property | Type | Description |
| --- | --- | --- |
| `closed` | `string` | Displays when the issue or pull request is closed. |
| `merged` | `string` | Displays when the pull request is merged. Applicable to pull requests only. |


## Contributing

1. Fork it ( https://github.com/masutaka/github-nippou/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## External articles

In Japanese

1. [いつも日報書くときに使っているスクリプトをGem化した | マスタカの ChangeLog メモ](https://masutaka.net/2014-12-07-1/)
1. [github-nippou v0.1.1 released | マスタカの ChangeLog メモ](https://masutaka.net/2014-12-18-1/)
1. [github-nippou v1.1.0 and v1.1.1 released | マスタカの ChangeLog メモ](https://masutaka.net/2016-03-21-1/)
1. [github-nippou v1.2.0 released | マスタカの ChangeLog メモ](https://masutaka.net/2016-03-23-1/)
1. [社内勉強会で github-nippou v2.0.0 をライブリリースした | マスタカの ChangeLog メモ](https://masutaka.net/2016-04-09-1/)
1. [github-nippou v3.0.0 released | マスタカの ChangeLog メモ](https://masutaka.net/2017-08-07-1/)
1. [github-nippou という gem を golang で書き直したという発表をした - Feedforce Developer Blog](https://developer.feedforce.jp/entry/2017/10/16/150000)
1. [github-nippou を golang で書き換えて v4.0.1 リリースしてました | マスタカの ChangeLog メモ](https://masutaka.net/2017-10-22-1/)
1. [github-nippou のリリースを gox+ghr の手動実行から、tagpr+goreleaser の自動実行に変えた | マスタカの ChangeLog メモ](https://masutaka.net/2023-11-14-1/)
