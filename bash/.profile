# bash login shell. zsh is the primary shell; this keeps PATH usable when bash
# is used (e.g. some Linux hosts or `bash -l`).

export VOLTA_HOME="$HOME/.volta"
[ -d "$VOLTA_HOME/bin" ] && export PATH="$VOLTA_HOME/bin:$PATH"

# Rancher Desktop
[ -d "$HOME/.rd/bin" ] && export PATH="$HOME/.rd/bin:$PATH"

# mise
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash --shims)"

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
