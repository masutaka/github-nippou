# github-nippou

[![Test](https://github.com/masutaka/github-nippou/actions/workflows/test.yml/badge.svg?branch=main)][Test]
[![Go Report Card](https://goreportcard.com/badge/github.com/masutaka/github-nippou/v4)][Go Report Card]
[![Go Reference](https://pkg.go.dev/badge/github.com/masutaka/github-nippou/v4.svg)][Go Reference]
[![Ask DeepWiki](https://deepwiki.com/badge.svg)][DeepWiki]

[Test]: https://github.com/masutaka/github-nippou/actions/workflows/test.yml?query=branch%3Amain
[Go Report Card]: https://goreportcard.com/report/github.com/masutaka/github-nippou/v4
[Go Reference]: https://pkg.go.dev/github.com/masutaka/github-nippou/v4
[DeepWiki]: https://deepwiki.com/masutaka/github-nippou

<p>
  <a href="./README.md"><img alt="README in English" src="https://img.shields.io/badge/English-d9d9d9"></a>
  <a href="./README_ja.md"><img alt="日本語のREADME" src="https://img.shields.io/badge/日本語-d9d9d9"></a>
</p>

今日の GitHub 上の Issue と Pull Request のアクティビティを出力します。

GitHub を参照しながら日報を書くときに便利な CLI です。

## インストール

[リリースページ](https://github.com/masutaka/github-nippou/releases)から最新のバイナリを取得してください。

macOS では Homebrew を使ってインストールまたはアップデートできます:

```
$ brew install masutaka/tap/github-nippou
$ brew upgrade github-nippou
```

`github-nippou` の開発に興味がある場合は `go install` でインストールできます:

```
$ go install github.com/masutaka/github-nippou/v4@latest
```

make コマンドを使ってビルドすることもできます:

```
$ make deps
$ make
$ ./github-nippou
```

## セットアップ

    $ github-nippou init

初期化により [Git グローバル設定ファイル](https://git-scm.com/docs/git-config#Documentation/git-config.txt-XDGCONFIGHOMEgitconfig)が更新されます。

1. `github-nippou.user` を追加
2. `github-nippou.token` を追加
3. Gist を作成し、出力形式をカスタマイズするための `github-nippou.settings-gist-id` を追加（任意）

## 使い方

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

今日の GitHub 日報を取得できます。

```
$ github-nippou

### masutaka/github-nippou

* [v3.0.0](https://github.com/masutaka/github-nippou/issues/59) by @[masutaka](https://github.com/masutaka)
* [Enable to inject settings_gist_id instead of the settings](https://github.com/masutaka/github-nippou/pull/63) by @[masutaka](https://github.com/masutaka) **merged!**
* [Add y/n prompt to sub command \`init\`](https://github.com/masutaka/github-nippou/pull/64) by @[masutaka](https://github.com/masutaka) **merged!**
* [Add sub command \`open-settings\`](https://github.com/masutaka/github-nippou/pull/65) by @[masutaka](https://github.com/masutaka) **merged!**
* [Dockerize](https://github.com/masutaka/github-nippou/pull/66) by @[masutaka](https://github.com/masutaka) **merged!**
```

## ライブラリとしての利用例

以下のプロジェクトが github-nippou をライブラリとして利用しています:

* https://github.com/MH4GF/github-nippou-web
    * github-nippou の Web アプリ版
* https://github.com/NoritakaIkeda/GitJournal
    * github-nippou の出力を GitHub Discussion に投稿できる Web アプリ

## オプション: 出力形式のカスタマイズ

必要に応じてリスト出力の形式をカスタマイズできます。設定は Gist に保存されます。  
`github-nippou init` を実行すると Gist が作成され、その ID が `github-nippou.settings-gist-id` に追加されます。

デフォルトの設定は[こちら](./config/settings.yml)で確認できます。

### 利用可能なプロパティ

#### `format.subject`

| プロパティ | 型 | 説明 |
| --- | --- | --- |
| `subject` | `string` | リポジトリ名を表します。 |

#### `format.line`

| プロパティ | 型 | 説明 |
| --- | --- | --- |
| `user` | `string` | Issue または Pull Request の作成者のユーザー名を表示します。 |
| `title` | `string` | Issue または Pull Request のタイトルを表示します。 |
| `url` | `string` | Issue または Pull Request の URL を表示します。 |
| `status` | `string \| nil` | `dictionary.status` の形式を利用してステータスを表示します。 |

#### `format.dictionary.status`

| プロパティ | 型 | 説明 |
| --- | --- | --- |
| `closed` | `string` | Issue または Pull Request がクローズされたときに表示されます。 |
| `merged` | `string` | Pull Request がマージされたときに表示されます。Pull Request のみに適用されます。 |

## 制限事項と遅延

github-nippou は GitHub の [List events for the authenticated user](https://docs.github.com/en/rest/activity/events?apiVersion=2026-03-10#list-events-for-the-authenticated-user) API を使用しています。

> This API is not built to serve real-time use cases. Depending on the time of day, event latency can be anywhere from 30s to 6h.

上記の通り、取得されるイベントには 30 秒から 6 時間の遅延が生じる場合があります。

:link: [REST API endpoints for events \- GitHub Docs](https://docs.github.com/en/rest/activity/events?apiVersion=2026-03-10)

> Only events created within the past 30 days will be included. Events older than 30 days will not be included (even if the total number of events in the timeline is less than 300).

github-nippou は過去の日報を作成することもできますが、取得できるイベントは過去 30 日以内かつ最大 300 件までです。

## コントリビューション

1. フォークする ( https://github.com/masutaka/github-nippou/fork )
2. フィーチャーブランチを作成する (`git checkout -b my-new-feature`)
3. 変更をコミットする (`git commit -am 'Add some feature'`)
4. ブランチにプッシュする (`git push origin my-new-feature`)
5. Pull Request を作成する

## コントリビューターの皆さん

<a href="https://github.com/masutaka/github-nippou/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=masutaka/github-nippou" />
</a>

*[contrib.rocks](https://contrib.rocks) で作成。*

## 外部記事

1. [いつも日報書くときに使っているスクリプトをGem化した | マスタカの ChangeLog メモ](https://masutaka.net/2014-12-07-1/)
1. [github-nippou v0.1.1 released | マスタカの ChangeLog メモ](https://masutaka.net/2014-12-18-1/)
1. [github-nippou v1.1.0 and v1.1.1 released | マスタカの ChangeLog メモ](https://masutaka.net/2016-03-21-1/)
1. [github-nippou v1.2.0 released | マスタカの ChangeLog メモ](https://masutaka.net/2016-03-23-1/)
1. [社内勉強会で github-nippou v2.0.0 をライブリリースした | マスタカの ChangeLog メモ](https://masutaka.net/2016-04-09-1/)
1. [github-nippou v3.0.0 released | マスタカの ChangeLog メモ](https://masutaka.net/2017-08-07-1/)
1. [github-nippou という gem を golang で書き直したという発表をした - Feedforce Developer Blog](https://developer.feedforce.jp/entry/2017/10/16/150000)
1. [github-nippou を golang で書き換えて v4.0.1 リリースしてました | マスタカの ChangeLog メモ](https://masutaka.net/2017-10-22-1/)
1. [github-nippou のリリースを gox+ghr の手動実行から、tagpr+goreleaser の自動実行に変えた | マスタカの ChangeLog メモ](https://masutaka.net/2023-11-14-1/)
1. [github\-nippou の Web 版を App Router \+ Go \+ Vercel で作った \| Hirotaka Miyagi](https://www.mh4gf.dev/articles/github-nippou-web)
1. [github\-nippou のリリース時に formula ファイルも自動更新するようにした \| マスタカの ChangeLog メモ](https://masutaka.net/2024-07-30-1/)
1. [github-nippou 10 周年 🎉 | マスタカの ChangeLog メモ](https://masutaka.net/2024-12-07-1/)
