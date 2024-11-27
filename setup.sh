#!/bin/bash

os_type=$(uname)

echo "☕️ Detecting OS..."

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

    echo "OS detected: 🐧 $NAME"

    echo "☕️ Verifying if ZSH is default shell..."

    if [[ "$SHELL" != *"zsh" ]]; then
        echo "❌ zsh is not the default shell. Exiting..."
        exit 1
    else
        echo "✅ ZSH is default shell"
    fi

    echo "☕️ Updating..."

    sudo apt update && sudo apt upgrade -y || { echo "❌ Update failed!"; exit 1; }
    echo "✅ Update completed"

    echo "☕️ Installing tools..."
    sudo apt install -y wget git unzip bat neofetch xclip build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
    echo "✅ Tools installed"
elif [[ "$os_type" == "Darwin" ]]; then
    echo "OS detected: 🍎 macOS"

    echo "☕️ Verifying if ZSH is default shell..."

    if [[ "$SHELL" != *"zsh" ]]; then
        echo "❌ zsh is not the default shell. Exiting..."
        exit 1
    else
        echo "✅ ZSH is default shell"
    fi

    if ! command -v brew &>/dev/null; then
        echo "☕️ Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "✅ Homebrew installed"
        echo "☕️ Reloading ZSH shell..."
        source ~/.zshrc
        echo "✅ ZSH shell reloaded"
    else
        echo "✅ Homebrew is already installed."
    fi

    echo "☕️ Updating Homebrew..."
    brew update
    brew upgrade
    echo "✅ Homebrew updated"

    echo "☕️ Installing Homebrew console tools..."
    brew install bat scc openssl readline sqlite3 xz zlib tcl-tk
    echo "✅ Homebrew console tools installed"

    echo "☕️ Installing Homebrew Casks..."
    brew install --cask appcleaner dbeaver-community discord docker figma google-chrome macs-fan-control \
        microsoft-auto-update microsoft-teams microsoft-word microsoft-excel microsoft-powerpoint microsoft-outlook \
        onedrive microsoft-onenote mongodb-compass notion postman rectangle runjs sourcetree spotify visual-studio-code whatsapp
    echo "✅ Homebrew casks tools installed"
fi

echo "☕️ Installing Pyenv..."
curl https://pyenv.run | bash
echo "✅ Pyenv installed"

echo "☕️ Installing rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "✅ Rust installed"

echo "☕️ Creating ssh directory..."
mkdir -p ~/.ssh
echo "✅ SSH directory created"

cd ~/.ssh || exit

echo "☕️ Generating ssh key for GitHub..."
read -p "SSH Key name: " ssh_key_name
read -p "GitHub email: " github_email

ssh-keygen -t ed25519 -b 4096 -C "$github_email" -f "$ssh_key_name" -N ""
eval "$(ssh-agent -s)"
ssh-add "$ssh_key_name"

if [[ -z "$ssh_key_name" ]]; then
    echo "❌ SSH key name is not set."
    exit 1
fi

if [[ "$os_type" == "Linux" ]]; then
    cat <<EOL > ~/.ssh/config
# Personal Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  IdentityFile ~/.ssh/$ssh_key_name
EOL
elif [[ "$os_type" == "Darwin" ]]; then
    cat <<EOL > ~/.ssh/config
# Personal Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/$ssh_key_name
EOL
fi
echo "✅ GitHub SSH key generated"

if [[ "$os_type" == "Linux" ]]; then
    xclip -selection clipboard < ~/.ssh/$ssh_key_name.pub || echo "xclip not installed, unable to copy SSH key."
else
    pbcopy < ~/.ssh/$ssh_key_name.pub
fi

read -p "Have you added the SSH key to your GitHub account? (yes/no): " ssh_added
if [[ "$ssh_added" == "yes" ]]; then
    ssh -T git@github.com
    echo "✅ GitHub SSH added"
else
    echo "⏩ Skipping SSH connection test. Please remember to test your SSH connection after adding the key."
fi

echo "☕️ Configuring global git..."
read -p "Complete name: " git_complete_name
git config --global user.name "$git_complete_name"
git config --global user.email "$github_email"
git config --global core.editor "code --wait"
read -p "Global gitignore file path: " git_global_gitignore_file_path
git config --global core.excludesfile "$git_global_gitignore_file_path"
read -p "Default init branch: " git_default_init_branch
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
EOL
echo "✅ Global git configured"

touch ~/.hushlogin

echo "☕️ Creating work directories..."
mkdir -p ~/dev/magnotechnology
echo "✅ Work directories created"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "✅ Oh My Zsh is already installed."
else
    echo "☕️ Installing Oh My Zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    echo "✅ Oh My Zsh installed."
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

clone_zsh_plugin() {
    local plugin_name=$1
    local plugin_repo=$2
    local plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"

    if [[ -d "$plugin_dir" ]]; then
        echo "✅ ZSH plugin '${plugin_name}' is already installed."
    else
        echo "☕️ Cloning '${plugin_name}' plugin..."
        git clone "$plugin_repo" "$plugin_dir"
        echo "✅ '${plugin_name}' plugin installed."
    fi
}

clone_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
clone_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
clone_zsh_plugin "you-should-use" "https://github.com/MichaelAquilina/zsh-you-should-use.git"
clone_zsh_plugin "zsh-bat" "https://github.com/fdellwing/zsh-bat.git"

echo "☕️ Editing ZSH configuration file..."

cat <<EOL > ~/.zshrc
# Oh My Zsh installation.
#export ZSH="\$HOME/.oh-my-zsh"

# Theme
#ZSH_THEME="robbyrussell"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)

#source "\$ZSH/oh-my-zsh.sh"

# Custom aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias home="cd ~ && erd"
alias dev="cd ~/dev && erd"
alias gpm="gp origin main"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glgm="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --author='edgarben27@gmail.com'"
alias l="erd"
alias ls="erd"

# Pyenv
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"

# Cargo
export CARGO_ROOT="$HOME/.cargo"
[[ -d \$CARGO_ROOT/bin ]] && export PATH="\$CARGO_ROOT/bin:\$PATH"

# Fnm
eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"
EOL

echo "✅ ZSH configuration file edited"

echo "☕️ Installing fnm..."
curl -fsSL https://fnm.vercel.app/install | bash
echo "✅ Fnm installed"

echo "☕️ Reloading ZSH shell..."
source ~/.zshrc
echo "✅ ZSH shell reloaded"

echo "☕️ Installing python..."
pyenv install 2
pyenv install 3
pyenv global 3
echo "✅ Python versions installed"

echo "☕️ Installing setuptools..."
pip install --upgrade pip
python -m pip install setuptools
echo "✅ Setuptools installed"

echo "☕️ Installing Node.js LTS..."
fnm install --lts
if [[ "$os_type" == "Linux" ]]; then
    NODE_LTS_VERSION=$(fnm ls | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fnm default "$NODE_LTS_VERSION"
elif [[ "$os_type" == "Darwin" ]]; then
    NODE_LTS_VERSION=$(fnm ls | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fnm default "$NODE_LTS_VERSION"
fi
echo "✅ Node.js LTS installed and set as default"

echo "☕️ Installing Erdtree..."
cargo install erdtree
echo "✅ Erdtree installed"

echo "☕️ Adding Erdtree configuration..."
cat <<EOL > ~/.erdtreerc
--level 2
--icons
--human
-s size
EOL
echo "✅ Erdtree configuration added"

ZSHRC_FILE=~/.zshrc

if [[ "$os_type" == "Darwin" ]]; then
    sed -i '' 's/^#\(export ZSH="\$HOME\/.oh-my-zsh"\)/\1/' "$ZSHRC_FILE"
    sed -i '' 's/^#\(ZSH_THEME="robbyrussell"\)/\1/' "$ZSHRC_FILE"
    sed -i '' 's/^#\(source "\$ZSH\/oh-my-zsh.sh"\)/\1/' "$ZSHRC_FILE"
    sed -i '' 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|' "$ZSHRC_FILE"
else
    sed -i 's/^#\(export ZSH="\$HOME\/.oh-my-zsh"\)/\1/' "$ZSHRC_FILE"
    sed -i 's/^#\(ZSH_THEME="robbyrussell"\)/\1/' "$ZSHRC_FILE"
    sed -i 's/^#\(source "\$ZSH\/oh-my-zsh.sh"\)/\1/' "$ZSHRC_FILE"
    sed -i 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|' "$ZSHRC_FILE"
fi

cd ~

echo "🎉 Environment setup completed!"

exec "$SHELL"
