# bash interactive shell. Minimal on purpose; zsh is the primary shell.

# Rancher Desktop
case ":$PATH:" in
  *":$HOME/.rd/bin:"*) ;;
  *) [ -d "$HOME/.rd/bin" ] && export PATH="$HOME/.rd/bin:$PATH" ;;
esac
