# Github::Nippou

[![Travis Status](https://img.shields.io/travis/masutaka/github-nippou.svg?style=flat-square)][travisci]
[![License](https://img.shields.io/github/license/masutaka/github-nippou.svg?style=flat-square)][license]
[![Gem](https://img.shields.io/gem/v/github-nippou.svg?style=flat-square)][gem-link]
[![Docker Stars](https://img.shields.io/docker/stars/masutaka/github-nippou.svg?style=flat-square)][dockerhub]
[![Docker Pulls](https://img.shields.io/docker/pulls/masutaka/github-nippou.svg?style=flat-square)][dockerhub]
[![Docker Automated buil](https://img.shields.io/docker/automated/masutaka/github-nippou.svg?style=flat-square)][dockerhub]

[travisci]: https://travis-ci.org/masutaka/github-nippou
[license]: https://github.com/masutaka/github-nippou/blob/master/LICENSE.txt
[gem-link]: http://badge.fury.io/rb/github-nippou
[dockerhub]: https://hub.docker.com/r/masutaka/github-nippou/

Print today's your GitHub action.

This is a helpful tool when you write a daily report in reference to
GitHub. Nippou is a japanese word which means a daily report.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'github-nippou'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github-nippou

## Setup

    $ github-nippou init

The initialization will be update your `~/.gitconfig`.

1. Add `github-nippou.user`
2. Add `github-nippou.token`
3. Create Gist, and add `github-nippou.settings-gist-id` for customizing output format (optional)

## Usage

```
$ github-nippou help
Commands:
  github-nippou help [COMMAND]  # Describe available commands or one specific command
  github-nippou init            # Initialize github-nippou settings
  github-nippou list            # Print today's your GitHub action (Default)
  github-nippou open-settings   # Open settings url with web browser
  github-nippou version         # Print version

Options:
  s, [--since-date=SINCE_DATE]  # Retrieves GitHub user_events since the date
                                # Default: 20170819
  u, [--until-date=UNTIL_DATE]  # Retrieves GitHub user_events until the date
                                # Default: 20170819
  d, [--debug], [--no-debug]    # Debug mode

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

## Docker

You can use the [dockerized github-nippou](https://hub.docker.com/r/masutaka/github-nippou/) via `bin/docker-github-nippou`.

    $ git clone https://github.com/masutaka/github-nippou.git
    $ cd github-nippou/bin
    $ ./docker-github-nippou help

However, you cannot use the sub command `open-settings`.

## Contributing

1. Fork it ( https://github.com/masutaka/github-nippou/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## External article

In Japanese

[github-nippou - GitHubから日報を作成 MOONGIFT](http://www.moongift.jp/2016/06/github-nippou-github%E3%81%8B%E3%82%89%E6%97%A5%E5%A0%B1%E3%82%92%E4%BD%9C%E6%88%90/)
