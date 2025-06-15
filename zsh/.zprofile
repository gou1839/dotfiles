# Amazon Q pre block
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"

# Python設定
PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# JetBrains Toolbox
export PATH="$PATH:/Users/gou/Library/Application Support/JetBrains/Toolbox/scripts"

# Volta（Node.jsバージョン管理）
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# pipx
export PATH="$PATH:/Users/gou/.local/bin"

# Amazon Q post block
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
eval $(/opt/homebrew/bin/brew shellenv)
