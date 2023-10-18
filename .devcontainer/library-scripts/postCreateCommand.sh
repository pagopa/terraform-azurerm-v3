#!/bin/bash

tfenv install

# /bin/bash ./.devcontainer/library-scripts/homebrew-setup.sh

# install oh-my-posh
sudo curl -s https://ohmyposh.dev/install.sh | bash -s

# install fzf binaries
# sudo apk add fzf

pwsh ./.devcontainer/library-scripts/powershell-setup.ps1
