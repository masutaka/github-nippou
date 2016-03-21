# Github::Nippou [![Gem Version][gem-badge]][gem-link]

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

Options:
  a, [--all], [--no-all]  # Displays all events that can retrieve from GitHub
```

You can omit the sub command `list`.

## Contributing

1. Fork it ( https://github.com/masutaka/github-nippou/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[gem-badge]: https://badge.fury.io/rb/github-nippou.svg
[gem-link]: http://badge.fury.io/rb/github-nippou
