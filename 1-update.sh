#!/bin/bash

# Update distro
sudo apt update && sudo apt upgrade -y

# Install essentials tools
sudo apt install -y wget zsh git unzip bat neofetch xclip build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev

# Install Oh My ZSH without switching to Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --skip-chsh

# Add zsh to allowed shells if not already added
if ! grep -Fxq "$(which zsh)" /etc/shells; then
  sudo sh -c 'echo $(which zsh) >> /etc/shells'
fi

# Run the final Zsh command
zsh -i <(curl -s https://raw.githubusercontent.com/Edd27/wsl2-devenv-setup/main/2-configure.sh)
