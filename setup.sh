#!/bin/bash

set -euo pipefail

clear

#-------------------------------#
#         SETUP VARIABLES       #
#-------------------------------#

readonly PYTHON_VERSION="3"
readonly ZSHRC_FILE="$HOME/.zshrc"
readonly SCRIPT_NAME="$(basename "$0")"
readonly GITHUB_SSH_KEY_NAME="id_rsa_github_personal"
readonly LOG_FILE="/tmp/devenv_setup_$(date +%Y%m%d_%H%M%S).log"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

#-------------------------------#
#         HELPER FUNCTIONS      #
#-------------------------------#

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

error() {
    log "${RED}❌ ERROR: $1${NC}"
    exit 1
}

success() {
    log "${GREEN}✅ $1${NC}"
}

info() {
    log "${BLUE}ℹ️  $1${NC}"
}

warning() {
    log "${YELLOW}⚠️  $1${NC}"
}

progress() {
    log "${CYAN}☕️ $1${NC}"
}

check_command() {
    if ! command -v "$1" &>/dev/null; then
        return 1
    fi
    return 0
}

install_package() {
    local package="$1"
    progress "Installing $package..."
    if sudo apt install -y "$package" &>>"$LOG_FILE"; then
        success "$package installed"
    else
        error "Failed to install $package"
    fi
}

clone_zsh_plugin() {
    local plugin_name="$1"
    local plugin_repo="$2"
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${plugin_name}"

    if [[ ! -d "$plugin_dir" ]]; then
        progress "Cloning '$plugin_name' plugin..."
        if git clone "$plugin_repo" "$plugin_dir" &>>"$LOG_FILE"; then
            success "'$plugin_name' plugin installed"
        else
            error "Failed to clone $plugin_name plugin"
        fi
    else
        success "'$plugin_name' plugin already exists"
    fi
}

validate_input() {
    local input="$1"
    local default="$2"

    if [[ -z "$input" ]]; then
        echo "$default"
    else
        echo "$input"
    fi
}

#-------------------------------#
#          START BANNER         #
#-------------------------------#

show_banner() {
    log "\n${CYAN}"
    log "██████╗ ███████╗██╗   ██╗███████╗███╗   ██╗██╗   ██╗"
    log "██╔══██╗██╔════╝██║   ██║██╔════╝████╗  ██║██║   ██║"
    log "██║  ██║█████╗  ██║   ██║█████╗  ██╔██╗ ██║██║   ██║"
    log "██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║╚██╗ ██╔╝"
    log "██████╔╝███████╗ ╚████╔╝ ███████╗██║ ╚████║ ╚████╔╝ "
    log "╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝  ╚═══╝  "
    log "\n🚀 Starting development environment setup...${NC}\n"
    info "Log file: $LOG_FILE"
}

#-------------------------------#
#          OS CHECK             #
#-------------------------------#

check_os() {
    progress "Detecting OS..."
    sleep 1

    if [[ "$(uname)" != "Linux" ]]; then
        error "Unsupported OS: $(uname)"
    fi

    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        if [[ "$NAME" != "Ubuntu" && "$NAME" != "Debian GNU/Linux" ]]; then
            error "Unsupported distribution: $NAME"
        fi
        success "OS detected: 🐧 $NAME"
    else
        error "Cannot detect OS distribution"
    fi
}

#-------------------------------#
#     CHECK ZSH AS DEFAULT      #
#-------------------------------#

setup_zsh() {
    progress "Verifying if ZSH is default shell..."
    
    if [[ -z "${ZSH_VERSION:-}" ]]; then
        warning "ZSH is not the current shell. Switching..."
        
        if ! check_command zsh; then
            progress "Installing ZSH..."
            sudo apt update &>>"$LOG_FILE" || error "Failed to update package list"
            install_package zsh
        else
            success "ZSH already installed at $(command -v zsh)"
        fi

        local zsh_path
        zsh_path=$(command -v zsh)
        progress "Setting ZSH as your default shell..."
        
        if sudo chsh -s "$zsh_path" "$USER" &>>"$LOG_FILE"; then
            success "Default shell changed to ZSH"
        else
            error "Failed to change default shell"
        fi

        [[ ! -f "$HOME/.zshrc" ]] && echo "# .zshrc placeholder" > "$HOME/.zshrc"

        if [[ "${SCRIPT_ALREADY_RESTARTED:-}" != "true" ]]; then
            info "Restarting script in ZSH..."
            export SCRIPT_ALREADY_RESTARTED="true"
            exec zsh -c "source '$0'"
        fi
    else
        success "Currently running inside ZSH"
    fi
}

#-------------------------------#
#      USER INFO FOR GIT        #
#-------------------------------#

get_user_info() {
    echo -n "Enter your complete name: "
    read -r git_complete_name
    git_complete_name=$(validate_input "$git_complete_name" "Developer")

    echo -n "Enter your email: "
    read -r user_email
    user_email=$(validate_input "$user_email" "developer@example.com")

    info "Using: $git_complete_name <$user_email>"
}

#-------------------------------#
#       LOCALE SETUP            #
#-------------------------------#

setup_locale() {
    progress "Setting up system locale (en_US.UTF-8)..."
    
    if locale -a | grep -q "en_US.utf8\|en_US.UTF-8"; then
        success "en_US.UTF-8 locale already installed"
    else
        progress "Installing en_US.UTF-8 locale..."
        
        if ! dpkg -l | grep -q "^ii  locales "; then
            install_package locales
        fi
        
        if sudo locale-gen en_US.UTF-8 &>>"$LOG_FILE"; then
            success "en_US.UTF-8 locale generated"
        else
            warning "Failed to generate en_US.UTF-8 locale"
        fi
    fi
    
    progress "Setting en_US.UTF-8 as default locale..."
    
    if sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 &>>"$LOG_FILE"; then
        success "Default locale set to en_US.UTF-8"
    else
        warning "Failed to set default locale"
    fi
    
    if ! grep -q "export LANG=en_US.UTF-8" "$ZSHRC_FILE" 2>/dev/null; then
        {
            echo ""
            echo "# Locale configuration"
            echo "export LANG=en_US.UTF-8"
            echo "export LC_ALL=en_US.UTF-8"
        } >> "$ZSHRC_FILE"
        success "Locale exports added to ~/.zshrc"
    fi
    
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
}

#-------------------------------#
#    ESSENTIAL TOOLS INSTALL    #
#-------------------------------#

install_essentials() {
    progress "Installing essential tools..."

    sudo apt update &>>"$LOG_FILE" || error "Failed to update package list"
    sudo apt upgrade -y &>>"$LOG_FILE" || warning "Some packages failed to upgrade"

    local packages=(
        wget curl git unzip bat neofetch xclip make build-essential
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
        libncursesw5-dev libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev
        libffi-dev liblzma-dev libgdbm-dev libnss3-dev libexpat1-dev
        fontconfig locales
    )

    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            install_package "$package"
        fi
    done

    sudo apt clean -y &>>"$LOG_FILE"
    sudo apt autoremove -y &>>"$LOG_FILE"

    success "Essential tools installed"
}

#-------------------------------#
#    JETBRAINS MONO FONTS       #
#-------------------------------#

install_jetbrains_mono_fonts() {
    progress "Installing JetBrains Mono Fonts (Normal + Nerd Font)..."
    
    local font_dir="$HOME/.local/share/fonts"
    local temp_dir="/tmp/jetbrains_mono_fonts"
    local nerd_font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    local normal_font_url="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
    
    mkdir -p "$font_dir"
    
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    local nerd_installed=false
    local normal_installed=false
    
    if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        nerd_installed=true
    fi
    
    if fc-list | grep -qi "JetBrains Mono" && ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        normal_installed=true
    fi
    
    if [[ "$nerd_installed" == true && "$normal_installed" == true ]]; then
        success "JetBrains Mono fonts already installed (Normal + Nerd Font)"
        return 0
    fi
    
    if [[ "$nerd_installed" == false ]]; then
        progress "Downloading JetBrains Mono Nerd Font..."
        if curl -fsSL "$nerd_font_url" -o "$temp_dir/JetBrainsMonoNerd.zip" &>>"$LOG_FILE"; then
            success "Nerd Font downloaded successfully"
        else
            error "Failed to download JetBrains Mono Nerd Font"
        fi
        
        progress "Extracting Nerd Font files..."
        mkdir -p "$temp_dir/nerd"
        if unzip -o -q "$temp_dir/JetBrainsMonoNerd.zip" -d "$temp_dir/nerd" &>>"$LOG_FILE"; then
            success "Nerd Font files extracted"
        else
            error "Failed to extract Nerd Font files"
        fi
        
        progress "Installing Nerd Font files..."
        if find "$temp_dir/nerd" -name "*.ttf" -exec cp {} "$font_dir/" \; &>>"$LOG_FILE"; then
            success "Nerd Font files copied to $font_dir"
        else
            error "Failed to copy Nerd Font files"
        fi
    else
        info "JetBrains Mono Nerd Font already installed, skipping..."
    fi
    
    if [[ "$normal_installed" == false ]]; then
        progress "Downloading JetBrains Mono Normal Font..."
        if curl -fsSL "$normal_font_url" -o "$temp_dir/JetBrainsMonoNormal.zip" &>>"$LOG_FILE"; then
            success "Normal Font downloaded successfully"
        else
            error "Failed to download JetBrains Mono Normal Font"
        fi
        
        progress "Extracting Normal Font files..."
        mkdir -p "$temp_dir/normal"
        if unzip -o -q "$temp_dir/JetBrainsMonoNormal.zip" -d "$temp_dir/normal" &>>"$LOG_FILE"; then
            success "Normal Font files extracted"
        else
            error "Failed to extract Normal Font files"
        fi
        
        progress "Installing Normal Font files..."
        if find "$temp_dir/normal" -path "*/fonts/ttf/*.ttf" -o -name "*.ttf" | head -20 | xargs -I {} cp {} "$font_dir/" 2>>"$LOG_FILE"; then
            success "Normal Font files copied to $font_dir"
        else
            error "Failed to copy Normal Font files"
        fi
    else
        info "JetBrains Mono Normal Font already installed, skipping..."
    fi
    
    progress "Updating font cache..."
    if fc-cache -fv "$font_dir" &>>"$LOG_FILE"; then
        success "Font cache updated"
    else
        warning "Failed to update font cache"
    fi
    
    rm -rf "$temp_dir"
    
    progress "Verifying font installation..."
    
    info "Debug: Checking installed JetBrains fonts..."
    fc-list | grep -i "jetbrains" | head -10 >> "$LOG_FILE"
    
    local final_nerd_check=false
    local final_normal_check=false
    
    if fc-list | grep -i "jetbrains" | grep -i "nerd"; then
        final_nerd_check=true
    fi
    
    if fc-list | grep -i "jetbrains" | grep -v -i "nerd"; then
        final_normal_check=true
    fi
    
    if [[ "$final_nerd_check" == true && "$final_normal_check" == true ]]; then
        success "JetBrains Mono fonts installed successfully"
        info "Installed fonts:"
        info "  • JetBrains Mono (Normal) - For general system use"
        info "  • JetBrains Mono Nerd Font - For terminal with icons"
        info ""
        info "Usage:"
        info "  • Terminal: Look for 'JetBrains' or 'JetBrainsMono' with 'Nerd' in the name"
        info "  • IDE/Editor: Look for 'JetBrains Mono' in font selection"
        info ""
        info "Available fonts:"
        fc-list | grep -i "jetbrains" | cut -d: -f2 | sort -u | head -5
    else
        warning "Font installation may be incomplete"
        info "Debug information:"
        if [[ "$final_nerd_check" == true ]]; then
            info "✓ JetBrains Mono Nerd Font variants found"
        else
            warning "✗ JetBrains Mono Nerd Font variants not detected"
        fi
        if [[ "$final_normal_check" == true ]]; then
            info "✓ JetBrains Mono Normal Font variants found"
        else
            warning "✗ JetBrains Mono Normal Font variants not detected"
        fi
        info ""
        info "All JetBrains fonts found:"
        fc-list | grep -i "jetbrains" | cut -d: -f2 | sort -u
    fi
}

#-------------------------------#
#    DEV TOOLS INSTALLATION     #
#-------------------------------#

install_dev_tools() {
    progress "Installing development tools..."

    if [[ ! -d "$HOME/.pyenv" ]]; then
        if curl -fsSL https://pyenv.run | bash &>>"$LOG_FILE"; then
            success "Pyenv installed"
        else
            warning "Failed to install Pyenv"
        fi
    else
        success "Pyenv already installed"
    fi
    
    if [[ ! -d "$HOME/.fnm" ]]; then
        if curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.fnm" --skip-shell &>>"$LOG_FILE"; then
            sed -i 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|' "$ZSHRC_FILE"
            success "FNM installed"
        else
            warning "Failed to install FNM"
        fi
    else
        success "FNM already installed"
    fi
}

#-------------------------------#
#     OH-MY-ZSH + PLUGINS       #
#-------------------------------#

setup_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        progress "Installing Oh My Zsh..."
        if git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh &>>"$LOG_FILE"; then
            success "Oh My Zsh installed"
        else
            error "Failed to install Oh My Zsh"
        fi
    else
        success "Oh My Zsh already installed"
    fi

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    local plugins=(
        "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
        "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "you-should-use https://github.com/MichaelAquilina/zsh-you-should-use.git"
        "zsh-bat https://github.com/fdellwing/zsh-bat.git"
    )
    
    for plugin_info in "${plugins[@]}"; do
        local plugin_name plugin_repo
        plugin_name=$(echo "$plugin_info" | cut -d' ' -f1)
        plugin_repo=$(echo "$plugin_info" | cut -d' ' -f2)
        clone_zsh_plugin "$plugin_name" "$plugin_repo"
    done
}

#-------------------------------#
#       ZSH CONFIG FILE         #
#-------------------------------#

create_zshrc() {
    progress "Creating ZSH configuration..."

    cat > "$ZSHRC_FILE" << 'EOF'
# Git branch parser
parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
  echo "on $branch"
}

# Custom prompt colors
COLOR_BLUE=$'%F{blue}'
COLOR_GRAY=$'%F{245}'
COLOR_MAGENTA=$'%F{magenta}'
COLOR_GREEN=$'%F{green}'
COLOR_YELLOW=$'%F{yellow}'
COLOR_RED=$'%F{red}'
COLOR_DEFAULT=$'%f'

# Custom prompt
export PROMPT='${COLOR_YELLOW}[${COLOR_RED}%n${COLOR_GRAY}＠${COLOR_BLUE}%m${COLOR_YELLOW}]${COLOR_GRAY}:${COLOR_MAGENTA}%~${COLOR_GREEN} $(parse_git_branch)
${COLOR_MAGENTA}›${COLOR_DEFAULT} '

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Shell options
setopt auto_cd
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt share_history

# Enhanced cd with auto ls
cd() { 
    builtin cd "$@" && ls -la --color=auto
}

# Auto ls on directory change
chpwd() { 
    ls -la --color=auto
}

# Aliases
alias ls="ls -la --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias gpm="git push origin main"
alias gpo="git push origin"
alias gpl="git pull"
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gaa="git add ."
alias gcm="git commit -m"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Locale configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Development environment setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

export FNM_ROOT="$HOME/.fnm"
if [[ -d $FNM_ROOT ]]; then
    export PATH="$FNM_ROOT:$PATH"
    eval "$("$FNM_ROOT/fnm" env --use-on-cd --version-file-strategy=recursive --shell zsh)"
    if command -v fnm 1>/dev/null 2>&1; then
        fnm use --install-if-missing lts-latest 1>/dev/null 2>&1 || true
    fi
fi

# History configuration
HISTFILE=~/.zsh_history
HISTFILE=~/.bash_history
HISTSIZE=10000
SAVEHIST=10000
EOF

    success "ZSH configuration created"
}

#-------------------------------#
#      PYTHON & NODE SETUP      #
#-------------------------------#

setup_python_node() {
    progress "Setting up Python $PYTHON_VERSION..."
    
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    if command -v pyenv &>/dev/null; then
        eval "$(pyenv init -)"
        
        if pyenv versions | grep -q "$PYTHON_VERSION"; then
            info "Python $PYTHON_VERSION already installed"
        else
            progress "Installing Python $PYTHON_VERSION (this may take a while)..."
            
            if [[ -d "$PYENV_ROOT/versions/$PYTHON_VERSION" ]]; then
                rm -rf "$PYENV_ROOT/versions/$PYTHON_VERSION"
            fi
            
            if ! pyenv install "$PYTHON_VERSION" &>>"$LOG_FILE"; then
                error "Failed to install Python $PYTHON_VERSION. Check $LOG_FILE for details."
            fi
        fi
        
        if pyenv global "$PYTHON_VERSION" &>>"$LOG_FILE"; then
            success "Python $PYTHON_VERSION set as global version"
        else
            warning "Failed to set Python $PYTHON_VERSION as global"
        fi
        
        local python_path
        python_path=$(pyenv which python)
        local python_version_output
        python_version_output=$(python --version 2>&1)
        
        if [[ "$python_version_output" == *"$PYTHON_VERSION"* ]]; then
            success "Python verification successful: $python_version_output"
            
            if python -m ensurepip --upgrade &>>"$LOG_FILE" 2>&1; then
                success "pip ensured"
            else
                warning "Failed to ensure pip, trying alternative method"
                curl -sS https://bootstrap.pypa.io/get-pip.py | python &>>"$LOG_FILE" || warning "Failed to install pip"
            fi
            
            if command -v pip &>/dev/null; then
                pip install --upgrade pip &>>"$LOG_FILE" && success "pip upgraded"
                python -m pip install setuptools wheel &>>"$LOG_FILE" && success "setuptools and wheel installed"
            else
                warning "pip not available after Python installation"
            fi
        else
            warning "Python installation may be incomplete"
        fi
        
    else
        warning "Pyenv not available for Python setup"
    fi
    
    progress "Setting up Node.js LTS..."
    
    local fnm_root="$HOME/.fnm"
    if [[ -d "$fnm_root" ]] && [[ -x "$fnm_root/fnm" ]]; then
        export PATH="$fnm_root:$PATH"
        eval "$("$fnm_root/fnm" env --shell bash)"
        
        if "$fnm_root/fnm" install --lts &>>"$LOG_FILE"; then
            local node_version
            node_version=$("$fnm_root/fnm" current 2>/dev/null || echo "unknown")
            success "Node.js LTS installed: $node_version"
            info "Node.js will be fully available after shell restart"
        else
            warning "Failed to install Node.js LTS"
        fi
    else
        warning "FNM not available for Node.js setup"
    fi
}

#-------------------------------#
#    VERIFY GIT INSTALLATION    #
#-------------------------------#

verify_git_installation() {
    progress "Verifying Git installation..."

    if ! check_command git; then
        error "Git is not installed or not found in PATH. Please contact your system administrator to install Git."
    fi

    success "Git is installed: $(git --version)"
}

#-------------------------------#
#          SSH SETUP            #
#-------------------------------#

setup_ssh() {
    progress "Setting up SSH for GitHub..."

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    local ssh_key_path="$HOME/.ssh/$GITHUB_SSH_KEY_NAME"

    if [[ ! -f "$ssh_key_path" ]]; then
        if ssh-keygen -t rsa -b 4096 -C "$user_email" -f "$ssh_key_path" -N "" &>>"$LOG_FILE"; then
            success "SSH key generated"
        else
            error "Failed to generate SSH key"
        fi
    else
        success "SSH key already exists"
    fi

    if [[ -z "${SSH_AGENT_PID:-}" ]]; then
        eval "$(ssh-agent -s)" &>>"$LOG_FILE"
    fi

    if ssh-add "$ssh_key_path" &>>"$LOG_FILE"; then
        success "SSH key added to agent"
    else
        warning "Failed to add SSH key to agent"
    fi

    cat > ~/.ssh/config << EOF
# Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  IdentityFile ~/.ssh/$GITHUB_SSH_KEY_NAME
EOF

    chmod 600 ~/.ssh/config
    success "SSH configuration created"

    if check_command xclip; then
        if xclip -selection clipboard < "${ssh_key_path}.pub"; then
            success "SSH key copied to clipboard — paste it in GitHub"
        else
            warning "Failed to copy SSH key to clipboard"
        fi
    else
        warning "xclip not available — copy key manually from: ${ssh_key_path}.pub"
    fi
}

#-------------------------------#
#          GIT CONFIG           #
#-------------------------------#

configure_git() {
    progress "Configuring global Git settings..."

    git config --global user.name "$git_complete_name"
    git config --global user.email "$user_email"
    git config --global core.editor "code --wait"
    git config --global core.excludesfile "$HOME/.gitignore"
    git config --global init.defaultbranch "main"
    git config --global core.fileMode false
    git config --global --add safe.directory '*'
    git config --global core.autocrlf input
    git config --global pull.rebase false

    cat > ~/.gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Build outputs
.next/
dist/
build/
out/

# Environment files
.env*
!.env.example

# IDE
.vscode/
.cursor/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Package manager
.npmrc
*-lock.json
yarn.lock
pnpm-lock.yaml

# Version files
.nvmrc
.node-version
.python-version

# Misc
.eslint*
*.gyp
EOF

    touch ~/.hushlogin
    success "Global Git configuration completed"
}

#-------------------------------#
#        MAIN FUNCTION          #
#-------------------------------#

main() {
    show_banner
    check_os
    setup_zsh
    get_user_info
    setup_locale
    install_essentials
    install_jetbrains_mono_fonts
    install_dev_tools
    setup_oh_my_zsh
    create_zshrc
    setup_python_node
    verify_git_installation
    setup_ssh
    configure_git

    success "🎉 Environment for development setup completed!"
    info "📝 Configuration summary:"
    info "   • Locale: en_US.UTF-8"
    info "   • Font: JetBrains Mono Nerd Font"
    info "   • Shell: ZSH with Oh My Zsh"
    info "   • Python: $PYTHON_VERSION (via pyenv)"
    info "   • Node.js: LTS (via fnm)"
    info "🔄 Please restart your terminal (on WSL) or your session (on Linux Distro) to apply changes"
    info "🖥️ To use the Nerd Font, set your terminal font to 'JetBrainsMono Nerd Font'"
    info "📄 Log file saved at: $LOG_FILE"
}

#-------------------------------#
#        SCRIPT EXECUTION       #
#-------------------------------#

if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi
