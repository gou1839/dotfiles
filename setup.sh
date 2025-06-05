#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"

# zshの設定ファイルのシンボリックリンク作成
ln -sf "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Powerlevel10kの設定ファイル
ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# .configディレクトリが存在しない場合は作成
mkdir -p "$HOME/.config"

# .configディレクトリ内のシンボリックリンク作成
ln -sf "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Dotfiles setup completed!"
