#!/bin/bash

# Update distro
sudo apt update && sudo apt upgrade -y

# Install essentials tools
sudo apt install -y wget zsh git unzip bat neofetch xclip build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev

# Install Oh My ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Add zsh to allowed shells if not already added
if ! grep -Fxq "$(which zsh)" /etc/shells; then
  sudo sh -c 'echo $(which zsh) >> /etc/shells'
fi

# Set zsh as the default shell
chsh -s $(which zsh)

echo "zsh has been set as the default shell. Please log out and log back in for changes to take effect."
echo

# Configure development environment
curl -fsSL https://raw.githubusercontent.com/Edd27/wsl2-devenv-setup/main/2-configure.sh | bash
