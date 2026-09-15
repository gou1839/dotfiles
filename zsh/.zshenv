# Loaded by every zsh (login, interactive, scripts). Keep it minimal.

# Volta (Node.js version manager). Only added when installed.
export VOLTA_HOME="$HOME/.volta"
[[ -d "$VOLTA_HOME/bin" ]] && export PATH="$VOLTA_HOME/bin:$PATH"
