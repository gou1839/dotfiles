# 🚀 Dotfiles Setup Script

## 📁 ディレクトリ構成

```
dotfiles/
├── setup.sh                    # メインのセットアップスクリプト
├── README.md                   # このファイル
├── .p10k.zsh                   # Powerlevel10k設定
├── zsh/
│   ├── .zshenv                 # zsh環境変数設定
│   ├── .zprofile              # zshプロファイル設定
│   └── .zshrc                 # zshメイン設定
└── .config/
    ├── nvim/                  # Neovim設定
    └── starship.toml          # Starshipプロンプト設定
```

## 🚀 インストール・実行方法

### 1. リポジトリをクローン

```bash
git clone https://github.com/gou1839/dotfiles.git
cd ~/dotfiles
```

### 2. セットアップスクリプトを実行

```bash
# 実行権限を付与
chmod +x setup.sh

# セットアップ実行
./setup.sh
```

## 🎯 セットアップ内容

このスクリプトは以下のシンボリックリンクを作成するで：

### Zsh設定ファイル
- `~/dotfiles/zsh/.zshenv` → `~/.zshenv`
- `~/dotfiles/zsh/.zprofile` → `~/.zprofile`
- `~/dotfiles/zsh/.zshrc` → `~/.zshrc`

### Powerlevel10k設定
- `~/dotfiles/.p10k.zsh` → `~/.p10k.zsh`

### アプリケーション設定
- `~/dotfiles/.config/nvim` → `~/.config/nvim`
- `~/dotfiles/.config/starship.toml` → `~/.config/starship.toml`


## 🛡️ 安全機能

### バックアップ機能
既存のファイルがある場合は、自動でバックアップを作成するで：
- `~/.zshrc.backup.20241225_143022` みたいな感じでタイムスタンプ付きでバックアップ

### エラーハンドリング
- ソースファイルが存在しない場合はエラー表示
- dotfilesディレクトリが見つからない場合は処理を停止
- シンボリックリンク作成に失敗した場合はエラー表示

## 🔧 トラブルシューティング

### よくある問題

**Q: `Permission denied` エラーが出る**
```bash
chmod +x setup.sh
```

**Q: dotfilesディレクトリが見つからない**
- `~/dotfiles` にリポジトリがクローンされてるか確認
- パスが正しいか確認

**Q: 設定が反映されない**
```bash
# ターミナルを再起動するか
source ~/.zshrc
```

## 📝 カスタマイズ

スクリプトをカスタマイズしたい場合は、`setup.sh` の以下の部分を編集：

- `DOTFILES_DIR`: dotfilesディレクトリのパス
- `create_symlink` 関数の呼び出し部分: 追加したいシンボリックリンク


---

**Happy coding! 🎉** 
