#!/bin/bash

os_type=$(uname)

echo -e "☕️ Detecting OS...\n"

sleep 2

if [[ "$os_type" != "Linux" ]] && [[ "$os_type" != "Darwin" ]]; then
    echo "❌ Unsupported OS: $os_type"
    exit 1
fi

if [[ "$os_type" == "Linux" ]]; then
    source /etc/os-release

    if [[ "$NAME" != "Ubuntu" ]] && [[ "$NAME" != "Debian GNU/Linux" ]]; then
        echo "❌ Unsupported distribution: $NAME"
        exit 1
    fi

    echo -e "OS detected: 🐧 $NAME\n"

    echo -e "☕️ Verifying if ZSH is default shell...\n"

    if [[ "$SHELL" != *"zsh" ]]; then
        echo "❌ zsh is not the default shell. Exiting..."
        exit 1
    else
        echo -e "✅ ZSH is default shell\n"
    fi

    echo -e "☕️ Installing tools...\n"
    sudo apt install -y wget git unzip bat neofetch xclip build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
    echo -e "✅ Tools installed\n"
elif [[ "$os_type" == "Darwin" ]]; then
    echo -e "OS detected: 🍎 macOS\n"

    echo -e "☕️ Verifying if ZSH is default shell...\n"

    if [[ "$SHELL" != *"zsh" ]]; then
        echo "❌ zsh is not the default shell. Exiting..."
        exit 1
    else
        echo -e "✅ ZSH is default shell\n"
    fi

    if ! command -v brew &>/dev/null; then
        echo -e "☕️ Installing Homebrew...\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo -e "✅ Homebrew installed\n"
        echo -e "☕️ Reloading ZSH shell...\n"
        source ~/.zshrc
        echo -e "✅ ZSH shell reloaded\n"
    else
        echo -e "✅ Homebrew is already installed\n"
    fi

    echo -e "☕️ Updating Homebrew...\n"
    brew update
    brew upgrade
    echo -e "✅ Homebrew updated\n"

    echo -e "☕️ Installing Homebrew console tools...\n"
    brew install bat scc openssl readline sqlite3 xz zlib tcl-tk gh
    echo -e "✅ Homebrew console tools installed\n"

    echo -e "☕️ Installing Homebrew Casks...\n"
    brew install --cask appcleaner bruno claude cursor dbeaver-community dbngin docker google-chrome keyboardcleantool libreoffice macs-fan-control \
        rectangle spotify visual-studio-code vlc warp windows-app
    echo -e "✅ Homebrew casks tools installed\n"
fi

echo -e "☕️ Installing Pyenv...\n"
curl https://pyenv.run | bash
echo -e "✅ Pyenv installed\n"

echo -e "☕️ Installing rust...\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo -e "✅ Rust installed\n"

read -p "🛠 Do you want to generate and configure an SSH key for GitHub? (yes/no): " generate_ssh
generate_ssh=$(echo "$generate_ssh" | tr '[:upper:]' '[:lower:]' | xargs)

if [[ "$generate_ssh" == "yes" ]]; then
    echo -e "☕️ Creating ssh directory...\n"
    mkdir -p ~/.ssh
    echo -e "✅ SSH directory created\n"

    cd ~/.ssh || exit

    echo -e "☕️ Generating ssh key for GitHub...\n"
    read -p "Enter SSH Key name (press Enter to use default: GitHub): " ssh_key_name
    ssh_key_name=${ssh_key_name:-github_personal}
    read -p "Enter your GitHub email: " github_email
    github_email=${github_email:-me@example.com}
    ssh_key_complete_name="id_rsa_$ssh_key_name"
    ssh-keygen -t ed25519 -b 4096 -C "$github_email" -f "$ssh_key_complete_name" -N ""
    eval "$(ssh-agent -s)"
    ssh-add "$ssh_key_complete_name"

    if [[ "$os_type" == "Linux" ]]; then
        cat <<EOL > ~/.ssh/config
# Personal Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  IdentityFile ~/.ssh/$ssh_key_complete_name
EOL
    elif [[ "$os_type" == "Darwin" ]]; then
        cat <<EOL > ~/.ssh/config
# Personal Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/$ssh_key_complete_name
EOL
    fi
    echo -e "✅ GitHub SSH key generated\n"

    if [[ "$os_type" == "Linux" ]]; then
        xclip -selection clipboard < ~/.ssh/$ssh_key_complete_name.pub && echo -e "📋 SSH Key copied to clipboard, past to your GitHub account\n" || echo -e "xclip not installed, unable to copy SSH key\n"
    else
        pbcopy < ~/.ssh/$ssh_key_complete_name.pub
        echo -e "📋 SSH Key copied to clipboard, past to your GitHub account\n"
    fi

    read -p "Have you added the SSH key to your GitHub account? (yes/no): " ssh_added
    ssh_added=$(echo "$ssh_added" | tr '[:upper:]' '[:lower:]' | xargs)

    if [[ "$ssh_added" == "yes" ]]; then
        ssh -T git@github.com
        echo -e "✅ GitHub SSH added\n"
    else
        echo -e "⏩ Skipping SSH connection test. Please remember to test your SSH connection after adding the key\n"
    fi
else
    echo -e "⏩ Skipping SSH key generation and configuration\n"
fi

read -p "🛠 Do you want to configure global Git configuration? (yes/no): " generate_global_git_config
generate_global_git_config=$(echo "$generate_global_git_config" | tr '[:upper:]' '[:lower:]' | xargs)

if [[ "$generate_global_git_config" == "yes" ]]; then
    echo -e "☕️ Configuring global git...\n"
    read -p "Enter your complete name: " git_complete_name
    git config --global user.name "$git_complete_name"
    git config --global user.email "$github_email"
    git config --global core.editor "code --wait"
    read -p "Enter global gitignore file path (press Enter to use default: ~/.gitignore): " git_global_gitignore_file_path
    git_global_gitignore_file_path=${git_global_gitignore_file_path:-~/.gitignore}
    git config --global core.excludesfile "$git_global_gitignore_file_path"
    read -p "Enter the default init branch name (press Enter to use default: main): " git_default_init_branch
    git_default_init_branch=${git_default_init_branch:-main}
    git config --global init.defaultbranch "$git_default_init_branch"
    git config --global core.fileMode false
    git config --global --add safe.directory '*'
    git config --global core.autocrlf input

    touch ~/.gitignore && cat <<EOL > ~/.gitignore
node_modules
.next
dist
build
.npmrc
.nvmrc
.node-version
.python-version
.eslint*
*-lock.json
*.gyp
.vscode
.cursor
.env*
EOL
    echo -e "✅ Global git configuration updated\n"
else
    echo -e "⏩ Skipping global Git configuration\n"
fi

touch ~/.hushlogin

echo -e "☕️ Creating work directories...\n"
mkdir -p ~/dev
echo -e "✅ Work directories created\n"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "✅ Oh My Zsh is already installed\n"
else
    echo -e "☕️ Installing Oh My Zsh...\n"
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    echo -e "✅ Oh My Zsh installed\n"
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

clone_zsh_plugin() {
    local plugin_name=$1
    local plugin_repo=$2
    local plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"

    if [[ -d "$plugin_dir" ]]; then
        echo -e "✅ ZSH plugin '${plugin_name}' is already installed\n"
    else
        echo -e "☕️ Cloning '${plugin_name}' plugin...\n"
        git clone "$plugin_repo" "$plugin_dir"
        echo -e "✅ '${plugin_name}' plugin installed\n"
    fi
}

clone_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
clone_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_zsh_plugin "you-should-use" "https://github.com/MichaelAquilina/zsh-you-should-use.git"
clone_zsh_plugin "zsh-bat" "https://github.com/fdellwing/zsh-bat.git"

echo -e "☕️ Editing ZSH configuration file...\n"

cat <<EOL > ~/.zshrc
# Prompt
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/git:(\1)/p'
}
COLOR_USER=\$'%F{green}'
COLOR_SEPARATOR=\$'%F{8}'
COLOR_HOSTNAME=\$'%F{magenta}'
COLOR_PATH=\$'%F{yellow}'
COLOR_GIT=\$'%F{cyan}'
COLOR_DEF=\$'%f'
export PROMPT='\${COLOR_USER}%n\${COLOR_SEPARATOR}＠\${COLOR_HOSTNAME}%m\${COLOR_PATH} %~\${COLOR_GIT} \$(parse_git_branch)\${COLOR_DEF}
'

# Oh My Zsh installation.
#export ZSH="\$HOME/.oh-my-zsh"

# Theme
#ZSH_THEME=""

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)

#source "\$ZSH/oh-my-zsh.sh"

# Custom aliases
setopt auto_cd
cd() {
  builtin cd "\$@" && ls -la --color=auto
}
alias ls="ls -la --color=auto"
chpwd() {
  ls -la --color=auto
}
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias gpm="gp origin main"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Pyenv
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"

# Cargo
export CARGO_ROOT="\$HOME/.cargo"
[[ -d \$CARGO_ROOT/bin ]] && export PATH="\$CARGO_ROOT/bin:\$PATH"
EOL

echo -e "✅ ZSH configuration file edited\n"

echo -e "☕️ Installing fnm...\n"
curl -fsSL https://fnm.vercel.app/install | bash
echo -e "✅ Fnm installed"

echo -e "☕️ Reloading ZSH shell...\n"
source ~/.zshrc
echo -e "✅ ZSH shell reloaded\n"

echo -e "☕️ Installing python...\n"
pyenv install 3
pyenv global 3
echo -e "✅ Python versions installed\n"

echo -e "☕️ Installing setuptools...\n"
pip install --upgrade pip
python -m pip install setuptools
echo -e "✅ Setuptools installed\n"

echo -e "☕️ Installing Node.js LTS...\n"
fnm install --lts
if [[ "$os_type" == "Linux" ]]; then
    NODE_LTS_VERSION=$(fnm ls | grep 'lts-latest' | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fnm default "$NODE_LTS_VERSION"
elif [[ "$os_type" == "Darwin" ]]; then
    NODE_LTS_VERSION=$(fnm ls | grep 'lts-latest' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fnm default "$NODE_LTS_VERSION"
fi
echo -e "✅ Node.js $NODE_LTS_VERSION installed and set as default\n"

ZSHRC_FILE=~/.zshrc

if [[ "$os_type" == "Darwin" ]]; then
    sed -i '' 's/^#\(export ZSH="\$HOME\/.oh-my-zsh"\)/\1/' "$ZSHRC_FILE"
    sed -i '' 's/^#\(ZSH_THEME=""\)/\1/' "$ZSHRC_FILE"
    sed -i '' 's/^#\(source "\$ZSH\/oh-my-zsh.sh"\)/\1/' "$ZSHRC_FILE"
    sed -i '' 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|' "$ZSHRC_FILE"
    sed -i '' '/# Fnm/{N;/eval ""/d;}' "$ZSHRC_FILE"
else
    sed -i 's/^#\(export ZSH="\$HOME\/.oh-my-zsh"\)/\1/' "$ZSHRC_FILE"
    sed -i 's/^#\(ZSH_THEME=""\)/\1/' "$ZSHRC_FILE"
    sed -i 's/^#\(source "\$ZSH\/oh-my-zsh.sh"\)/\1/' "$ZSHRC_FILE"
    sed -i 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|' "$ZSHRC_FILE"
    sed -i '/# Fnm/{N;/eval ""/d;}' "$ZSHRC_FILE"
fi

cd ~

echo -e "🎉 \e[32mEnvironment setup completed!\e[0m\n"

exec "$SHELL"
