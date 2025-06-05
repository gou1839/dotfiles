#!/bin/bash

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# アニメーション用
SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

# スピナー関数
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr=$SPINNER
    echo -n " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ログ関数
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# プログレスバー関数
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r${BLUE}Progress: [${NC}"
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "${BLUE}] ${WHITE}%d%%${NC}" $percentage
}

# ヘッダー表示
print_header() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                   🚀 DOTFILES SETUP SCRIPT 🚀                ║"
    echo "║                                                                ║"
    echo "║                     Let's make it awesome!                     ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# ファイルの存在確認とシンボリックリンク作成
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    if [ -e "$source" ]; then
        if [ -L "$target" ]; then
            log_warning "$description already exists (symlink)"
            rm "$target"
        elif [ -e "$target" ]; then
            log_warning "$description already exists (backing up)"
            mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        
        ln -sf "$source" "$target" &
        spinner $!
        
        if [ $? -eq 0 ]; then
            log_success "$description linked successfully"
        else
            log_error "Failed to link $description"
            return 1
        fi
    else
        log_error "Source file not found: $source"
        return 1
    fi
}

# メイン処理
main() {
    print_header
    
    DOTFILES_DIR="$HOME/dotfiles"
    
    # ディレクトリ確認
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        exit 1
    fi
    
    log_info "Starting dotfiles setup..."
    echo
    
    # 総ステップ数
    TOTAL_STEPS=6
    CURRENT_STEP=0
    
    # zshの設定ファイルのシンボリックリンク作成
    log_info "Setting up Zsh configuration files..."
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    create_symlink "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv" ".zshenv"
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS  
    echo
    create_symlink "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile" ".zprofile"
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc" ".zshrc"
    
    # Powerlevel10kの設定ファイル
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Setting up Powerlevel10k configuration..."
    create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh"
    
    # .configディレクトリが存在しない場合は作成
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Setting up .config directory..."
    if [ ! -d "$HOME/.config" ]; then
        mkdir -p "$HOME/.config" &
        spinner $!
        log_success ".config directory created"
    else
        log_success ".config directory already exists"
    fi
    
    # .configディレクトリ内のシンボリックリンク作成
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Setting up application configurations..."
    create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "Neovim config"
    create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml" "Starship config"
    
    # 完了メッセージ
    echo
    progress_bar $TOTAL_STEPS $TOTAL_STEPS
    echo -e "\n"
    
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                    🎉 SETUP COMPLETED! 🎉                     ║"
    echo "║                                                                ║"
    echo "║              Your dotfiles are now ready to rock!              ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

# スクリプト実行
main "$@"
