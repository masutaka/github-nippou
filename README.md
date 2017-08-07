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

Displays today's your GitHub action.

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

    $ git config --global github-nippou.user [Your GitHub account]
    $ git config --global github-nippou.token [Your GitHub access token]

## Usage

```
$ github-nippou help
Commands:
  github-nippou help [COMMAND]  # Describe available commands or one specific command
  github-nippou list            # Displays today's GitHub events formatted for Nippou
  github-nippou version         # Displays version

Options:
  s, [--since-date=SINCE_DATE]  # Retrieves GitHub user_events since the date
                                # Default: 20160326
  u, [--until-date=UNTIL_DATE]  # Retrieves GitHub user_events until the date
                                # Default: 20160326
  d, [--debug], [--no-debug]    # Debug mode
```

You can get your GitHub Nippou on today.

```
$ github-nippou list
* [Bundle Update on 2016-03-24 - masutaka/awesome-github-feed](https://github.com/masutaka/awesome-github-feed/pull/38) by deppbot **merged!**
* [Fix performance - masutaka/github-nippou](https://github.com/masutaka/github-nippou/pull/44) by masutaka **merged!**
* [Bundle Update on 2016-03-24 - masutaka/masutaka-29hours](https://github.com/masutaka/masutaka-29hours/pull/19) by deppbot **merged!**
* [Bundle Update on 2016-03-24 - masutaka/masutaka-metrics](https://github.com/masutaka/masutaka-metrics/pull/34) by deppbot **merged!**
* [bundle update at 2016-03-25 18:32:43 JST - masutaka/masutaka.net](https://github.com/masutaka/masutaka.net/pull/52) by masutaka **merged!**
* [bundle update at 2016-03-25 10:02:02 UTC - masutaka/server-masutaka.net](https://github.com/masutaka/server-masutaka.net/pull/211) by masutaka **merged!**
```

You can omit the sub command `list`.

## Contributing

1. Fork it ( https://github.com/masutaka/github-nippou/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Docker

You can use the dockerized github-nippou via `bin/docker-github-nippou`.

    $ bin/docker-github-nippou help

See also https://hub.docker.com/r/masutaka/github-nippou/

## External article

In Japanese

[github-nippou - GitHubから日報を作成 MOONGIFT](http://www.moongift.jp/2016/06/github-nippou-github%E3%81%8B%E3%82%89%E6%97%A5%E5%A0%B1%E3%82%92%E4%BD%9C%E6%88%90/)
