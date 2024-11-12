#!/bin/bash

# Create work directories if they do not exist
mkdir -p ~/dev/magnotechnology
echo "✔️ Work directories created successfully."
echo

# Install ZSH plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" > /dev/null 2>&1
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"> /dev/null 2>&1
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"> /dev/null 2>&1
git clone https://github.com/fdellwing/zsh-bat.git "$ZSH_CUSTOM/plugins/zsh-bat"> /dev/null 2>&1
echo "✔️ Plugins cloned successfully."
echo

# Update plugins in .zshrc
sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)/' ~/.zshrc
echo "✔️ ZSH plugins updated successfully."
echo

# Restart shell to apply pyenv changes
source ~/.zshrc

# Install pyenv
curl https://pyenv.run | bash

# Configure pyenv in .zshrc
echo -e '\n# pyenv\nexport PYENV_ROOT="$HOME/.pyenv"\n[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init -)"\n# pyenv end\n' >> ~/.zshrc
echo "✔️ pyenv configured successfully."
echo

# Restart shell to apply pyenv changes
source ~/.zshrc

# Install Python versions using pyenv
pyenv install 2
pyenv install 3
pyenv global 3
echo "✔️ Python versions installed successfully."
echo

# Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Configure pnpm in .zshrc
echo -e '\n# pnpm\nexport PNPM_HOME="$HOME/.local/share/pnpm"\ncase ":$PATH:" in\n  *":$PNPM_HOME:"*) ;;\n  *) export PATH="$PNM_HOME:$PATH" ;;\nesac\n# pnpm end\n' >> ~/.zshrc

# Restart shell to apply pyenv changes
source ~/.zshrc

# Set Node.js version with pnpm
pnpm -g env use 18

# Install corepack globally
pnpm add -g corepack
echo "✔️ pnpm installed successfully."
echo

# Create global .gitignore
touch ~/.gitignore

# Set Git global configurations
git config --global user.name "Edgar Benavides"
git config --global user.email "edgarben27@gmail.com"
git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global init.defaultbranch main
git config --global core.fileMode false
git config --global core.excludesfile ~/.gitignore

# Create SSH directory and generate key
mkdir -p ~/.ssh
cd ~/.ssh || exit # Ensure we are in the directory or exit on error.
ssh-keygen -t ed25519 -b 4096 -C "edgarben27@gmail.com" -f GitHub_Edd27 -N ""

# Initialize SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add GitHub_Edd27

# Add SSH config for GitHub Account
cat <<EOL > ~/.ssh/config
# Personal Github
Host github.com
  HostName github.com
  PreferredAuthentications publickey
  AddKeysToAgent yes
  IdentityFile ~/.ssh/GitHub_Edd27
EOL

# Copy the new SSH key to clipboard (ensure xclip is installed)
xclip -selection clipboard < GitHub_Edd27.pub || echo "xclip not installed, unable to copy SSH key."

# Prompt user to confirm if they have added the SSH key to their GitHub account
read -p "Have you added the SSH key to your GitHub account? (yes/no): " ssh_added

if [[ "$ssh_added" == "yes" ]]; then
  # Test SSH connection to GitHub
  ssh -T git@github.com
else
  echo "Skipping SSH connection test. Please remember to test your SSH connection after adding the key."
fi

echo "✔️ Git configurations set successfully."
echo

# Suppress login messages by creating a .hushlogin file.
touch ~/.hushlogin

# Add aliases to .zshrc for convenience.
cat <<EOL >> ~/.zshrc

# Custom aliases
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias pn="pnpm"
alias home="cd ~"
alias dev="cd ~/dev && pn -g env use 18"
alias gpm="gp origin main"
alias glg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glgm="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --author='edgarben27@gmail.com'"
alias rclaro="cd ~/dev/magnotechnology/render-claro-co && pyenv shell 2 && code ."
alias apiclaro="cd ~/dev/magnotechnology/api-claro-co && pyenv shell 2 && code ."
EOL

echo "✔️ Aliases added successfully."
echo

cd ~

echo "🎉 Environment setup completed!"

# Final shell restart to apply changes.
exec "$SHELL"


