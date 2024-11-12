#!/bin/bash

# Update distro
sudo apt update && sudo apt upgrade -y

# Install essentials tools
sudo apt install -y wget zsh git unzip bat neofetch xclip build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev

# Install Oh My ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set ZSH as default shell
chsh -s $(which zsh)
