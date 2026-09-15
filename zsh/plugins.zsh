# zsh plugin loader (no plugin manager).
#
# Plugins are shallow git clones under $ZSH_PLUGIN_HOME and sourced directly.
# This replaced zplug, which cost ~300ms on every startup.
#
#   zsh-plugins-install   clone plugins that are missing
#   zsh-plugins-update    git pull every installed plugin
#   zsh-plugins-clean     remove plugins that are no longer listed
#
# setup.sh runs the install step as:
#   zsh -c 'source zsh/plugins.zsh && zsh-plugins-install'

typeset -g ZSH_PLUGIN_HOME="${ZSH_PLUGIN_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}"

# Load order matters: zsh-syntax-highlighting must come last.
typeset -ga ZSH_PLUGINS=(
  romkatv/powerlevel10k
  zsh-users/zsh-completions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-autosuggestions
  chrissicool/zsh-256color
  agkozak/zsh-z
  mrowa44/emojify
  zsh-users/zsh-syntax-highlighting
)

zsh-plugins-dir() { print -r -- "$ZSH_PLUGIN_HOME/${1:t}"; }

zsh-plugins-install() {
  local repo dir
  for repo in "${ZSH_PLUGINS[@]}"; do
    dir="$(zsh-plugins-dir "$repo")"
    [[ -d "$dir/.git" ]] && continue
    print -r -- "[zsh-plugins] installing $repo"
    git clone --quiet --depth 1 "https://github.com/${repo}.git" "$dir" || return 1
  done
}

zsh-plugins-update() {
  local repo dir
  for repo in "${ZSH_PLUGINS[@]}"; do
    dir="$(zsh-plugins-dir "$repo")"
    [[ -d "$dir/.git" ]] || continue
    print -r -- "[zsh-plugins] updating $repo"
    git -C "$dir" pull --quiet --ff-only
    command rm -f "$dir"/**/*.zwc(N)
  done
}

zsh-plugins-clean() {
  local dir keep
  for dir in "$ZSH_PLUGIN_HOME"/*(N/); do
    keep=0
    for repo in "${ZSH_PLUGINS[@]}"; do
      [[ "${repo:t}" == "${dir:t}" ]] && keep=1 && break
    done
    (( keep )) && continue
    print -r -- "[zsh-plugins] removing ${dir:t}"
    command rm -rf -- "$dir"
  done
}

# Returns 0 when every listed plugin is present.
zsh-plugins-installed() {
  local repo
  for repo in "${ZSH_PLUGINS[@]}"; do
    [[ -d "$(zsh-plugins-dir "$repo")/.git" ]] || return 1
  done
  return 0
}

# Source a plugin's entry file. Completion-only and command-only plugins are
# handled by the caller (fpath / PATH), so they are skipped here.
zsh-plugins-source() {
  local dir="$(zsh-plugins-dir "$1")" f
  [[ -d "$dir" ]] || return 0
  case "${1:t}" in
    zsh-completions) fpath=("$dir/src" $fpath); return 0 ;;
    emojify)         path=("$dir" $path);       return 0 ;;
  esac
  for f in "$dir"/*.plugin.zsh(N[1]) "$dir"/*.zsh-theme(N[1]); do
    source "$f"
    return 0
  done
  print -ru2 -- "[zsh-plugins] no entry file found for $1"
}

zsh-plugins-load() {
  local repo
  for repo in "${ZSH_PLUGINS[@]}"; do
    zsh-plugins-source "$repo"
  done
}
