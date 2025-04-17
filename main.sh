#!/bin/bash

# Suppress prompts by accepting defaults during Homebrew installation
NONINTERACTIVE=1

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install homebrew packages
curl https://raw.githubusercontent.com/konnorve/mac-setup/refs/heads/main/all.Brewfile | brew bundle --file=-

mamba init zsh bash

for file in *.yaml
do
mamba env create --file $file -y -v
done
