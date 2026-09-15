#!/usr/bin/env bash
# dotfiles setup.
#
#   ./setup.sh          link dotfiles into $HOME (default)
#   ./setup.sh install  install tools with Homebrew, then link
#
# Supported: macOS (Apple Silicon / Intel) and Linux (via Homebrew on Linux).
# macOS-only pieces (Rancher Desktop cask) are skipped elsewhere with a warning.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
OS="$(uname -s)"

info()    { printf '[INFO] %s\n' "$1"; }
success() { printf '[OK] %s\n' "$1"; }
warn()    { printf '[WARN] %s\n' "$1" >&2; }
die()     { printf '[ERROR] %s\n' "$1" >&2; exit 1; }

is_macos() { [[ "$OS" == "Darwin" ]]; }
is_linux() { [[ "$OS" == "Linux" ]]; }

link_file() {
  local source="$1"
  local target="$2"
  local description="$3"

  if [[ ! -e "$source" ]]; then
    warn "Skip $description: source not found: $source"
    return 0
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$source" ]]; then
      success "$description already linked"
      return 0
    fi
    rm "$target"
  elif [[ -e "$target" ]]; then
    mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
  fi

  ln -s "$source" "$target"
  success "$description -> $target"
}

# --- Homebrew -----------------------------------------------------------------

find_brew() {
  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew \
                   /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  command -v brew 2>/dev/null || return 1
}

ensure_brew() {
  local brew
  if brew="$(find_brew)"; then
    eval "$("$brew" shellenv)"
    return 0
  fi

  if is_linux; then
    local missing=()
    local dep
    for dep in curl git gcc; do
      command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
    done
    if (( ${#missing[@]} )); then
      warn "Homebrew on Linux needs: ${missing[*]}"
      warn "Debian/Ubuntu: sudo apt-get install -y build-essential procps curl file git"
      warn "Fedora/RHEL:   sudo dnf group install -y development-tools && sudo dnf install -y procps-ng curl file git"
      die "Install the prerequisites above, then re-run: $0 install"
    fi
  elif ! is_macos; then
    die "Unsupported OS: $OS (only macOS and Linux are supported)"
  fi

  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew="$(find_brew)" || die "Homebrew installed but brew not found on PATH"
  eval "$("$brew" shellenv)"
}

install_brew_package() {
  local package="$1"

  if brew list --formula "$package" >/dev/null 2>&1; then
    success "$package is already installed"
    return 0
  fi

  brew install "$package"
}

install_brew_cask() {
  local cask="$1"

  if ! is_macos; then
    warn "Skip cask $cask: casks are macOS only"
    return 0
  fi

  if brew list --cask "$cask" >/dev/null 2>&1; then
    success "$cask is already installed"
    return 0
  fi

  brew install --cask "$cask"
}

# --- tools ---------------------------------------------------------------------

install_tools() {
  ensure_brew

  info "Installing command line tools"
  # zsh: on Linux the login shell is often bash; install zsh so `chsh -s $(which zsh)` works.
  local packages=(zsh git gh neovim lsd bat sshuttle mise rbenv docker)
  local package
  for package in "${packages[@]}"; do
    install_brew_package "$package"
  done

  install_brew_cask rancher

  info "Installing zsh plugins"
  zsh -c "source '$DOTFILES_DIR/zsh/plugins.zsh' && zsh-plugins-install"

  if [[ ! -f "$HOME/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim" ]]; then
    info "Installing vim-jetpack"
    curl -fLo "$HOME/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim" \
      --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim
  fi

  if is_linux && [[ "${SHELL##*/}" != "zsh" ]]; then
    warn "Login shell is ${SHELL##*/}. Switch with: chsh -s \"\$(command -v zsh)\""
  fi
}

# --- links -----------------------------------------------------------------------

link_dotfiles() {
  info "Linking dotfiles from $DOTFILES_DIR"

  link_file "$DOTFILES_DIR/zsh/.zshenv"   "$HOME/.zshenv"   ".zshenv"
  link_file "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile" ".zprofile"
  link_file "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"    ".zshrc"
  link_file "$DOTFILES_DIR/bash/.profile" "$HOME/.profile"  ".profile"
  link_file "$DOTFILES_DIR/bash/.bashrc"  "$HOME/.bashrc"   ".bashrc"
  link_file "$DOTFILES_DIR/.p10k.zsh"     "$HOME/.p10k.zsh" ".p10k.zsh"

  link_file "$DOTFILES_DIR/.config/nvim"       "$HOME/.config/nvim"       "Neovim config"
  link_file "$DOTFILES_DIR/.config/git/ignore" "$HOME/.config/git/ignore" "Git global ignore"

  link_file "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json" "Claude settings"
  link_file "$DOTFILES_DIR/.claude/statusline.py" "$HOME/.claude/statusline.py" "Claude statusline"

  if is_macos; then
    link_file "$DOTFILES_DIR/.codex/config.toml"        "$HOME/.codex/config.toml"        "Codex config"
  else
    warn "Skip Codex config.toml: it contains macOS-only paths (see README)"
  fi
  link_file "$DOTFILES_DIR/.codex/rules/default.rules"  "$HOME/.codex/rules/default.rules"  "Codex default rules"
  link_file "$DOTFILES_DIR/.codex/rules/pr_read_rules.md" "$HOME/.codex/rules/pr_read_rules.md" "Codex PR read rules"
}

main() {
  [[ -d "$DOTFILES_DIR" ]] || die "Dotfiles directory not found: $DOTFILES_DIR"

  case "${1:-link}" in
    install)
      install_tools
      link_dotfiles
      ;;
    link)
      link_dotfiles
      ;;
    *)
      printf 'Usage: %s [link|install]\n' "$0" >&2
      exit 2
      ;;
  esac
}

main "$@"
