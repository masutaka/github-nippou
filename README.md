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
  github-nippou init            # Synchronize github-nippou settings on your gist
  github-nippou list            # Displays today's GitHub events formatted for Nippou (Default)
  github-nippou open-settings   # Open settings url with web browser
  github-nippou version         # Displays version

Options:
  s, [--since-date=SINCE_DATE]  # Retrieves GitHub user_events since the date
                                # Default: 20170807
  u, [--until-date=UNTIL_DATE]  # Retrieves GitHub user_events until the date
                                # Default: 20170807
  d, [--debug], [--no-debug]    # Debug mode

```

You can get your GitHub Nippou on today.

```
$ github-nippou

### masutaka/github-nippou

* [v3.0.0](https://github.com/masutaka/github-nippou/issues/59) by masutaka
* [Enable to inject settings_gist_id instead of the settings](https://github.com/masutaka/github-nippou/pull/63) by masutaka **merged!**
* [Add y/n prompt to sub command \`init\`](https://github.com/masutaka/github-nippou/pull/64) by masutaka **merged!**
* [Add sub command \`open-settings\`](https://github.com/masutaka/github-nippou/pull/65) by masutaka **merged!**
* [Dockerize](https://github.com/masutaka/github-nippou/pull/66) by masutaka **merged!**
```

## Customize output format

```
$ github-nippou init
This command will create a gist and update your `~/.gitconfig`.
Are you sure? [y/n] y
The github-nippou settings was created on https://gist.github.com/ecfa35cb546d8462277d133a91b13be9

And the gist_id was appended to your `~/.gitconfig`. You can
check the gist_id with following command.

    $ git config --global github-nippou.settings-gist-id
```

Open the Gist URL with your web browser.

```
$ github-nippou open-settings
Open https://gist.github.com/ecfa35cb546d8462277d133a91b13be9
```

## Docker

You can use the [dockerized github-nippou](https://hub.docker.com/r/masutaka/github-nippou/) via `bin/docker-github-nippou`.

    $ git clone https://github.com/masutaka/github-nippou.git
    $ cd github-nippou/bin
    $ ./docker-github-nippou help

## Contributing

1. Fork it ( https://github.com/masutaka/github-nippou/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## External article

In Japanese

[github-nippou - GitHubから日報を作成 MOONGIFT](http://www.moongift.jp/2016/06/github-nippou-github%E3%81%8B%E3%82%89%E6%97%A5%E5%A0%B1%E3%82%92%E4%BD%9C%E6%88%90/)
