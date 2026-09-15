# Dotfiles

zsh / Neovim / Claude Code / Codex の設定を管理する dotfiles です。
macOS を主環境としつつ、Linux でも同じ手順で使えるようにしています。

## 使い方

リンクだけ作成する場合:

```bash
./setup.sh
```

Homebrew パッケージや zsh プラグインも含めてセットアップする場合:

```bash
./setup.sh install
```

既存ファイルがある場合は `*.backup.YYYYMMDD_HHMMSS` として退避してからシンボリックリンクを作成します。
`DOTFILES_DIR` を指定しなければ、`setup.sh` があるディレクトリを dotfiles として扱います。

## 対応 OS

| 項目 | macOS | Linux | 備考 |
| --- | --- | --- | --- |
| zsh (`.zshenv` / `.zprofile` / `.zshrc`) | ✅ | ✅ | パスはすべて `$HOME` 基準。ツールが無ければ該当設定をスキップ |
| bash (`.profile` / `.bashrc`) | ✅ | ✅ | 最小構成 |
| Powerlevel10k (`.p10k.zsh`) | ✅ | ✅ | Nerd Font が必要 |
| Neovim (`.config/nvim`) | ✅ | ✅ | vim-jetpack は `setup.sh install` で導入 |
| Git global ignore | ✅ | ✅ | |
| Claude Code (`.claude/`) | ✅ | ✅ | hook / statusline は `$HOME` 基準 |
| Codex `config.toml` | ✅ | ❌ | `/Applications/...` や `/Users/gou/...` を含むため Linux ではリンクしない |
| Codex `rules/` | ✅ | ✅ | |
| Homebrew によるツール導入 | ✅ | ✅ | Linux は Homebrew on Linux を利用。要 `curl` `git` `gcc` |
| Rancher Desktop (cask) | ✅ | ❌ | Linux ではスキップ |

Ubuntu 24.04 コンテナで `setup.sh link` → `zsh -i -l` が警告なしに起動することを確認しています。

## zsh の起動時間

`.zshrc` は起動時間を優先して構成しています（このマシンで約 0.9 秒 → 約 0.15 秒）。
最初のプロンプト直前に `Started zsh in Nms` が表示されます。

主な方針:

- プラグインマネージャ（zplug）を廃止し、`zsh/plugins.zsh` で `git clone` したプラグインを直接 `source`
- `compinit` の dump を `~/.cache/zsh/` に置き、1 日 1 回だけ再生成（それ以外は `-C`）
- `gh` / `mise` の補完は生成結果をファイルにキャッシュし、バイナリが更新されたときだけ再生成
- `rbenv init` は `rbenv` コマンドを初めて使うまで遅延（shims は PATH に直接追加）
- 未使用だった nvm / zsh-async / dracula テーマ / zsh-abbr を削除

### プラグイン管理

```bash
zsh-plugins-install   # 未インストールのプラグインを clone
zsh-plugins-update    # 全プラグインを git pull
zsh-plugins-clean     # リストから外したプラグインを削除
```

プラグイン一覧は `zsh/plugins.zsh` の `ZSH_PLUGINS` で管理します。
インストール先は `~/.local/share/zsh/plugins/` です。旧 `~/.zplug` は不要なので削除して構いません。

## 管理対象

### Shell

- `~/.zshenv` -> `zsh/.zshenv`（Volta の PATH のみ）
- `~/.zprofile` -> `zsh/.zprofile`（Homebrew、JetBrains Toolbox、pipx の PATH）
- `~/.zshrc` -> `zsh/.zshrc`（対話シェル設定）
- `zsh/plugins.zsh`（`.zshrc` から読み込むプラグインローダー。リンクはしない）
- `~/.profile` -> `bash/.profile`
- `~/.bashrc` -> `bash/.bashrc`
- `~/.p10k.zsh` -> `.p10k.zsh`

Kiro CLI / Amazon Q / Rancher Desktop が自動挿入するブロックは dotfiles には含めません。
Rancher Desktop の PATH は `.zshrc` / `.bashrc` 側で `~/.rd/bin` を追加しているので、
Rancher Desktop の設定で PATH の自動管理は「Manual」にしてください。

#### Powerlevel10k

Powerlevel10k は Pure ベースの 2 行プロンプトです。

1 行目の左側:

- `user@host`: root または SSH のときだけ表示
- current directory
- Git status
- previous command duration: 直前のコマンドが 5 秒以上かかったときだけ表示

2 行目の左側:

- Python virtualenv: 有効なときだけ `py:<name>` 形式で表示
- prompt symbol: 成功時は `❯`、失敗時は赤い `❯`

右プロンプトは現在未使用です。現在時刻の設定はありますが、`time` セグメントはコメントアウトしています。

Git status は以下のように表示します。

- `branch-name*`: staged / unstaged / untracked のいずれかがある
- `branch-name ⇣`: remote より behind
- `branch-name ⇡`: remote より ahead
- `branch-name ⇣⇡`: remote と diverge
- `@commit`: detached HEAD

### Config

- `~/.config/nvim` -> `.config/nvim`
- `~/.config/git/ignore` -> `.config/git/ignore`

### Claude

- `~/.claude/settings.json` -> `.claude/settings.json`
- `~/.claude/statusline.py` -> `.claude/statusline.py`

履歴、cache、backup、local settings は管理しません。
`SessionStart` hook の `herdr-agent-state.sh` は herdr が `~/.claude/hooks/` に配置するもので、
存在しない環境では何もしません。

`settings.json` に残っているマシン固有の値（意図的に触っていません）:

- `extraKnownMarketplaces.compact-plus-local.source.path`: `/Users/gou/.claude/plugins/data/compact-plus`。
  GitHub 版 `compact-plus@compact-plus` も有効になっているため、片方は不要な可能性があります
- `autoMode.environment` の `Trusted repo`: Claude Code が自動生成した内容で、別リポジトリのパスを指しています

### Codex

- `~/.codex/config.toml` -> `.codex/config.toml`（macOS のみ）
- `~/.codex/rules/default.rules` -> `.codex/rules/default.rules`
- `~/.codex/rules/pr_read_rules.md` -> `.codex/rules/pr_read_rules.md`

認証情報、履歴、SQLite DB、cache は管理しません。

`config.toml` は Codex アプリが自動更新するファイルで、次のようなマシン固有の内容を含みます。
他機種で使う場合は `[tui]` と `[mcp_servers.*]` の必要な部分だけを手で移してください。

- `/Applications/Pencil.app`、`/Applications/ChatGPT.app` 配下の MCP サーバーパス
- `/Users/gou/...` を含む `notify`、`NODE_REPL_*`、`marketplaces.*.source`
- `[projects."..."]` の trust_level（このマシンのディレクトリ一覧）
- `[hooks.state]` のハッシュ

## 注意

`setup.sh install` は Homebrew（無ければインストール）、zsh、git、gh、neovim、lsd、bat、sshuttle、mise、rbenv、docker、
Rancher Desktop（macOS のみ）、zsh プラグイン、vim-jetpack をインストールします。
既に必要なツールが入っている環境では、通常は `./setup.sh` だけで十分です。

Node.js / pnpm は mise で管理しています。Volta は `~/.volta` が存在する場合だけ PATH に追加します。
