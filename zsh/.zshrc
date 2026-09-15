# ~/.zshrc — interactive shells only. PATH/env for login shells is in .zprofile.
#
# Startup budget: this file is tuned to start in well under 200ms.
# Heavy tools are guarded (skipped when not installed), evaluated once, cached,
# or lazily initialised. Check with the "Started zsh in Nms" line, or:
#   for i in 1 2 3; do /usr/bin/time zsh -i -c exit; done

# --- startup timer -----------------------------------------------------------
if zmodload zsh/datetime 2>/dev/null; then
  typeset -gF __DOTFILES_ZSH_START_TIME=$EPOCHREALTIME
fi

typeset -U path PATH fpath

# Put the prompt at the bottom of the terminal.
if [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
  printf '\n%.0s' {1..100}
fi

# --- plugins -----------------------------------------------------------------
# The plugin loader lives next to this file in the dotfiles repo. ~/.zshrc is a
# symlink, so resolve it to find the repo.
typeset -g DOTFILES_ZSH_DIR="${${(%):-%x}:A:h}"
source "$DOTFILES_ZSH_DIR/plugins.zsh"

# Anything that prints must run before Powerlevel10k instant prompt.
if ! zsh-plugins-installed; then
  zsh-plugins-install
fi

# --- Powerlevel10k instant prompt --------------------------------------------
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- history -----------------------------------------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# --- PATH: user-local tools (all guarded, all $HOME relative) ----------------
[[ -d "$HOME/.rd/bin" ]]  && path=("$HOME/.rd/bin" $path)   # Rancher Desktop
[[ -d "$HOME/.bun/bin" ]] && export BUN_INSTALL="$HOME/.bun" && path=("$BUN_INSTALL/bin" $path)

# pnpm home differs per OS.
case "$OSTYPE" in
  darwin*) export PNPM_HOME="$HOME/Library/pnpm" ;;
  *)       export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm" ;;
esac
[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)

# Google Cloud SDK
if [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# --- version managers --------------------------------------------------------
# mise (node, pnpm, ...). Single activation.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# rbenv: shims work without `rbenv init`, so only add them to PATH and run the
# (slow, ~200ms) init on first use of the `rbenv` command itself.
[[ -d "$HOME/.rbenv/bin" ]] && path=("$HOME/.rbenv/bin" $path)
if (( $+commands[rbenv] )); then
  path=("${RBENV_ROOT:-$HOME/.rbenv}/shims" $path)
  export RBENV_SHELL=zsh
  rbenv() {
    unfunction rbenv
    eval "$(command rbenv init - zsh --no-rehash)"
    rbenv "$@"
  }
fi

# --- completion --------------------------------------------------------------
# Generated completions are cached in fpath and only regenerated when the
# generating binary is newer than the cache file.
typeset -g __dotfiles_zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$__dotfiles_zsh_cache/completions"
fpath=("$__dotfiles_zsh_cache/completions" $fpath)

__dotfiles_cache_completion() {  # <command> <args...>  ->  completions/_<command>
  local cmd="$1" out="$__dotfiles_zsh_cache/completions/_$1"
  (( $+commands[$cmd] )) || return 0
  if [[ ! -s "$out" || "$commands[$cmd]" -nt "$out" ]]; then
    "$@" >| "$out" 2>/dev/null || command rm -f "$out"
  fi
}
__dotfiles_cache_completion gh completion -s zsh
__dotfiles_cache_completion mise completion zsh
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Plugins: this adds zsh-completions to fpath (before compinit) and sources the
# theme and the rest.
zsh-plugins-load

# compinit: re-scan fpath at most once per day, otherwise trust the dump (-C).
autoload -Uz compinit
typeset -g __dotfiles_zcompdump="$__dotfiles_zsh_cache/zcompdump-$ZSH_VERSION"
if [[ -n "$__dotfiles_zcompdump"(#qN.mh-24) ]]; then
  compinit -C -d "$__dotfiles_zcompdump"
else
  compinit -d "$__dotfiles_zcompdump"
fi
{ [[ ! -f "$__dotfiles_zcompdump.zwc" || "$__dotfiles_zcompdump" -nt "$__dotfiles_zcompdump.zwc" ]] \
    && zcompile "$__dotfiles_zcompdump" } &!

zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$__dotfiles_zsh_cache/compcache"
zstyle ':completion:*' list-separator '-->'

# Google Cloud SDK completion (needs compinit).
if [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# --- prompt ------------------------------------------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- aliases (fall back to coreutils when the fancy tool is missing) ---------
if (( $+commands[lsd] )); then
  alias lsa='lsd -a'
  alias ll='lsd -l'
  alias la='lsd -A'
  __dotfiles_ls_after_cd() { lsd -a; }
else
  alias lsa='ls -a'
  alias ll='ls -l'
  alias la='ls -A'
  __dotfiles_ls_after_cd() { ls -a; }
fi

if (( $+commands[bat] )); then
  alias cat='bat'
elif (( $+commands[batcat] )); then   # Debian/Ubuntu package name
  alias cat='batcat'
fi

if (( $+commands[nvim] )); then
  alias vi='nvim'
  alias zshrc="nvim $DOTFILES_ZSH_DIR/.zshrc"
else
  alias zshrc="${EDITOR:-vim} $DOTFILES_ZSH_DIR/.zshrc"
fi
alias v='vim'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias sdev='ssh dev'
alias ssdev='sshuttle -vr dev 172.16.0.0/12'
alias sstg='ssh stg'
alias ssstg='sshuttle -vr stg 10.0.0.0/8'

# clear keeps the prompt at the bottom.
alias clear="clear; tput cup 100"

# cd then list.
function cd() {
  builtin cd "$@" && __dotfiles_ls_after_cd
}

# --- startup time report (once, right before the first prompt) --------------
if [[ -n "${__DOTFILES_ZSH_START_TIME:-}" ]]; then
  autoload -Uz add-zsh-hook

  __dotfiles_report_zsh_startup_time() {
    emulate -L zsh
    add-zsh-hook -d precmd __dotfiles_report_zsh_startup_time

    local elapsed_ms=$(( int((EPOCHREALTIME - __DOTFILES_ZSH_START_TIME) * 1000) ))
    print -r -- "Started zsh in ${elapsed_ms}ms"

    unset __DOTFILES_ZSH_START_TIME
    unfunction __dotfiles_report_zsh_startup_time
  }

  add-zsh-hook precmd __dotfiles_report_zsh_startup_time
fi
