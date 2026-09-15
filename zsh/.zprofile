# Login shells only: PATH and environment. Interactive settings live in .zshrc.

typeset -U path PATH

# Homebrew: Apple Silicon, Intel macOS, Linuxbrew (system or per-user).
for __brew in /opt/homebrew/bin/brew /usr/local/bin/brew \
            /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [[ -x "$__brew" ]]; then
    eval "$("$__brew" shellenv)"
    break
  fi
done
unset __brew

# JetBrains Toolbox shell scripts (macOS / Linux locations).
for __jb in "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" \
          "$HOME/.local/share/JetBrains/Toolbox/scripts"; do
  [[ -d "$__jb" ]] && path+=("$__jb")
done
unset __jb

# pipx and other user-local installs.
path+=("$HOME/.local/bin")
