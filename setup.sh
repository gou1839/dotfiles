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
    TOTAL_STEPS=12  # 追加パッケージのインストールステップを追加
    CURRENT_STEP=0
    
    # Homebrewのインストール
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Checking Homebrew installation..."
    
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &
        spinner $!
        
        if [ $? -eq 0 ]; then
            log_success "Homebrew installed successfully"
        else
            log_error "Failed to install Homebrew"
            exit 1
        fi
    else
        log_success "Homebrew is already installed"
    fi
    
    # zplugのインストール
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Checking zplug installation..."
    
    if [ ! -d "$HOME/.zplug" ]; then
        log_info "Installing zplug..."
        curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh &
        spinner $!
        
        if [ $? -eq 0 ]; then
            log_success "zplug installed successfully"
            log_info "Other zsh plugins will be installed automatically via .zshrc"
        else
            log_error "Failed to install zplug"
            exit 1
        fi
    else
        log_success "zplug is already installed"
    fi
    
    # Neovimのインストール
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Checking Neovim installation..."
    
    if ! command -v nvim &> /dev/null; then
        log_info "Installing Neovim..."
        brew install neovim &
        spinner $!
        
        if [ $? -eq 0 ]; then
            log_success "Neovim installed successfully"
        else
            log_error "Failed to install Neovim"
            exit 1
        fi
    else
        log_success "Neovim is already installed"
    fi
    
    # Jetpackのインストール
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Checking Jetpack installation..."
    
    if [ ! -f "$HOME/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim" ]; then
        log_info "Installing Jetpack..."
        curl -fLo ~/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim &
        spinner $!
        
        if [ $? -eq 0 ]; then
            log_success "Jetpack installed successfully"
            log_info "Other Neovim plugins will be installed automatically via init.lua"
        else
            log_error "Failed to install Jetpack"
            exit 1
        fi
    else
        log_success "Jetpack is already installed"
    fi
    
    # コマンドラインツールのインストール
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Installing command line tools..."
    
    brew install lsd bat gh nvm rbenv sshuttle git docker &
    spinner $!
    
    if [ $? -eq 0 ]; then
        log_success "Command line tools installed successfully"
    else
        log_error "Failed to install command line tools"
        exit 1
    fi
    
    # Rancher Desktopのインストール
    CURRENT_STEP=$((CURRENT_STEP + 1))
    progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo
    log_info "Installing Rancher Desktop..."
    
    brew install --cask rancher &
    spinner $!
    
    if [ $? -eq 0 ]; then
        log_success "Rancher Desktop installed successfully"
    else
        log_error "Failed to install Rancher Desktop"
        exit 1
    fi
    
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
