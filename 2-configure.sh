#!/usr/bin/env zsh

# Install ZSH plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" > /dev/null 2>&1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" > /dev/null 2>&1
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use" > /dev/null 2>&1
git clone https://github.com/fdellwing/zsh-bat.git "$ZSH_CUSTOM/plugins/zsh-bat" > /dev/null 2>&1
echo "✔️ Plugins cloned successfully."
echo

# Install pyenv
curl https://pyenv.run | bash

# Install Rust (automating '1' input to confirm default installation)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "✔️ Rust installed successfully."
echo

# Generate SSH key
mkdir -p ~/.ssh
cd ~/.ssh || exit # Ensure we are in the directory or exit on error.
ssh-keygen -t ed25519 -b 4096 -C "edgarben27@gmail.com" -f GitHub_Edd27 -N ""
eval "$(ssh-agent -s)"
ssh-add GitHub_Edd27
echo "✔️ SSH key generated and added to agent."
echo

# Set Git global configurations
git config --global user.name "Edgar Benavides"
git config --global user.email "edgarben27@gmail.com"
git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global init.defaultbranch main
git config --global core.fileMode false
git config --global core.excludesfile ~/.gitignore
git config --global --add safe.directory ~/dev
echo "✔️ Git configurations set successfully."
echo

# Set up SSH config for GitHub
cat <<EOL > ~/.ssh/config
# Personal Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  IdentityFile ~/.ssh/GitHub_Edd27
EOL

# Create global .gitignore and add content
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
echo "✔️ Gitignore file created and populated."
echo

touch ~/.hushlogin

# Create work directories if they do not exist
mkdir -p ~/dev/magnotechnology
echo "✔️ Work directories created successfully."
echo

# Create configuration file for erdtree
cat <<EOL > ~/.erdtreerc
--level 2
--icons
--human
-s size
EOL
echo "✔️ .erdtreerc file created."
echo

# Configure all tools in .zshrc at once
cat <<EOL >> ~/.zshrc

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

# pyenv
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
# pyenv end

# rust
source "\$HOME/.cargo/env"
# rust end
EOL
echo "✔️ Configuration added to .zshrc."
echo

# Install fnm
curl -fsSL https://fnm.vercel.app/install | bash
echo "✔️ fnm installed successfully."
echo

# Update plugins in .zshrc
sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)/' ~/.zshrc

# Update flags to fnm env in .zshrc
sed -i 's|eval "`fnm env`"|eval "`fnm env --use-on-cd --version-file-strategy=recursive --shell zsh`"|g' ~/.zshrc

# Reload .zshrc to apply changes
source ~/.zshrc

# Install Python versions using pyenv
pyenv install 2
pyenv global 2
echo "✔️ Python versions installed successfully."
echo

# Upgrade pip and install setuptools
pip install --upgrade pip
python -m pip install setuptools
echo "✔️ pip upgraded and setuptools installed successfully."
echo

# Install Node.js
fnm install --lts
fnm default $(fnm current)
node -v
echo "✔️ Node.js installed successfully."
echo

# Install erdtree using Cargo
cargo install erdtree
echo "✔️ erdtree installed successfully."
echo

# Copy SSH key to clipboard (ensure xclip is installed)
xclip -selection clipboard < ~/.ssh/GitHub_Edd27.pub || echo "xclip not installed, unable to copy SSH key."

# Prompt user to confirm SSH key addition to GitHub
read -q "ssh_added?Have you added the SSH key to your GitHub account? (yes/no): "
echo

if [[ "$ssh_added" == "y" ]]; then
    ssh -T git@github.com
else
    echo "Skipping SSH connection test. Please remember to test your SSH connection after adding the key."
fi

# Move to ~
cd ~

echo "🎉 Environment setup completed!"

# Final shell restart to apply all changes
exec "$SHELL"
