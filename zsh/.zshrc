# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# promptを最下部に
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Amazon Q pre block
# zplugの初期化
export ZPLUG_HOME=$HOME/.zplug
source ~/.zplug/init.zsh

if [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
  printf '\n%.0s' {1..100}
fi

# zplugプラグイン
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "mafredri/zsh-async"                 # 非同期処理
zplug "zsh-users/zsh-syntax-highlighting"  # シンタックスハイライト
zplug "zsh-users/zsh-history-substring-search"  # コマンド履歴検索
zplug "zsh-users/zsh-autosuggestions"      # コマンドサジェスト
zplug "zsh-users/zsh-completions"          # 補完強化
zplug "chrissicool/zsh-256color"           # 256色対応
zplug "mrowa44/emojify", as:command        # 絵文字サポート
zplug "agkozak/zsh-z"                      # ディレクトリ移動
zplug "romkatv/powerlevel10k", as:theme, depth:1
zplug "dracula/zsh", as:theme

# プラグインのインストール
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# 履歴設定
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# エイリアス
alias zshrc="nvim ~/.zshrc"
alias vi='nvim'
alias v='vim'
alias ls='lsd'
alias lsa='lsd -a'
alias ll='lsd -l'
alias la='lsd -A'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias cat='bat'
alias sdev='ssh dev'
alias ssdev='sshuttle -vr dev 172.16.0.0/12'
alias sstg='ssh stg'
alias ssstg='sshuttle -vr stg 10.0.0.0/8'

# clearしたときにpromptが上に戻る問題を回避
alias clear="clear; tput cup 100"

# 補完設定
zstyle ':completion:*' use-cache true
zstyle ':completion:*' list-separator '-->'

# cd後に自動でls
function cd() {
    builtin cd $@ && ls;
}

# NVM設定
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Rancher Desktop
export PATH="/Users/gou/.rd/bin:$PATH"

# rbenv
export PATH=~/.rbenv/bin:$PATH
eval "$(rbenv init -)"

# その他のツール設定
eval "$(gh completion -s zsh)"  # GitHub CLI

# zplugのロード（最後に実行）
zplug load

# Amazon Q post block
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/gou/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
