#!/bin/bash

os_type=$(uname)

echo "☕️ Detecting OS..."

sleep 2

if [[ "$os_type" != "Linux" ]] && [[ "$os_type" != "Darwin" ]]; then
    echo "❌ Unsupported OS: $os_type"
    exit 1
fi

echo "☕️ Verifying if ZSH is default shell..."

if [[ "$SHELL" != *"zsh" ]]; then
    echo "❌ zsh is not the default shell. Exiting..."
    exit 1
else
    echo "✅ ZSH is default shell"
fi

if [[ "$os_type" == "Linux" ]]; then
  source /etc/os-release

  if [[ "$NAME" != "Ubuntu" ]] && [[ "$NAME" != "Debian GNU/Linux" ]]; then
    echo "❌ Unsupported distribution: $NAME"
    exit 1
  fi

  echo "OS detected: 🐧 $NAME"

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

  echo "☕️ Installing homebrew console tools..."

  brew install bat scc openssl readline sqlite3 xz zlib tcl-tk

  echo "✅ Homebrew console tools installed"

  echo "☕️ Installing Homebrew Casks..."

  brew install --cask appcleaner bitwarden brave-browser dbeaver-community discord docker figma macs-fan-control microsoft-auto-update microsoft-teams mongodb-compass notion postman rectangle runjs spotify visual-studio-code whatsapp

  echo "✅ Homebrew casks tools installed"

fi

echo "☕️ Installing Pyenv..."

if [[ "$os_type" == "Linux" ]]; then
  curl https://pyenv.run | bash
else
  brew install pyenv 
fi

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

echo "☕️ Adding erdtree configuration..."

cat <<EOL > ~/.erdtreerc
--level 2
--icons
--human
-s size
EOL

echo "✅ Erdtree configuration added"

echo "☕️ Editing ZSH configuration file..."

cat <<EOL >> ~/.zshrc

# Custom aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias home="cd ~ && erd"
alias dev="cd ~/dev && erd"
alias gpm="gp origin main"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glgm="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --author='$github_email'"
alias l="erd"
alias ls="erd"

# pyenv
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
# pyenv end

# rust
source "\$HOME/.cargo/env"
# rust end
EOL

sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)/' ~/.zshrc

sed -i 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|g' ~/.zshrc

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

echo "☕️ Installing Node.js LTS"

fnm install --lts
fnm default $(fnm current)
node -v

echo "✅ Node.js installed"

echo "☕️ Installing Erdtree..."

cargo install erdtree

echo "✅ Erdtree installed"

cd ~

echo "☕️ Instlling Oh my zsh..."

git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo "✅ Oh my zsh installed"

echo "☕️ Cloning ZSH plugins..."

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" > /dev/null 2>&1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" > /dev/null 2>&1
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use" > /dev/null 2>&1
git clone https://github.com/fdellwing/zsh-bat.git "$ZSH_CUSTOM/plugins/zsh-bat" > /dev/null 2>&1

echo "✅ ZSH plugins cloned"

echo "🎉 Environment setup completed!"

exec "$SHELL"
