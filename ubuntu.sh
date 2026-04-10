#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Base packages"
sudo apt update
sudo apt install -y \
  ca-certificates \
  curl \
  git \
  gpg \
  imagemagick \
  make \
  tree \
  wget \
  inkscape \
  libreoffice

echo "==> VS Code"
sudo snap install --classic code

echo "==> 1Password"
wget -O /tmp/1password.deb https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
sudo apt install -y /tmp/1password.deb
rm /tmp/1password.deb

echo "==> Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh

echo "==> Firefox"
sudo snap install firefox

echo "==> Spotify"
sudo snap install spotify

echo "==> Notion"
sudo snap install notion-desktop

echo "==> Zoom"
sudo snap install zoom-client

echo "==> WhiteSur GTK theme"
cd "$HOME"
rm -rf WhiteSur-gtk-theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
(
  cd WhiteSur-gtk-theme
  ./install.sh
)

echo "==> WhiteSur icon theme"
rm -rf WhiteSur-icon-theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
(
  cd WhiteSur-icon-theme
  ./install.sh
)

echo "==> Apply WhiteSur-Dark"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"

echo "==> Blur My Shell"
rm -rf blur-my-shell
git clone https://github.com/aunetx/blur-my-shell.git --depth=1
(
  cd blur-my-shell
  make install
)

gnome-extensions enable blur-my-shell@aunetx || true

echo
echo "Done."
echo
echo "Next steps:"
echo "  1. Log out and back in"
echo "  2. Run: sudo tailscale up"
