#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Base packages"
sudo apt update
sudo apt install -y \
  ca-certificates \
  curl \
  gettext \
  git \
  gpg \
  imagemagick \
  make \
  software-properties-common \
  tree \
  wget \
  inkscape \
  libreoffice

echo "==> GNOME: User Themes extension (for shell theme in ~/.themes)"
if sudo apt install -y gnome-shell-extension-user-theme; then
  :
else
  echo "    (Package not available from apt on this release — install “User Themes” via Extension Manager or extensions.gnome.org.)"
fi

echo "==> Extension Manager (snap) — install User Themes if apt had no package"
sudo snap install extension-manager || true

echo "==> keyd — Mac-style Command (Super) as Ctrl for shortcuts like copy/paste"
sudo add-apt-repository -y ppa:keyd-team/ppa
sudo apt update
sudo apt install -y keyd
sudo tee /etc/keyd/default.conf >/dev/null <<'KEYDEOF'
# Mac-style swap on a typical PC keyboard:
#   Physical Windows key  → Ctrl  (use Win+C / Win+V like macOS Cmd)
#   Physical Left Ctrl    → Super (press this for GNOME Activities / overview)
# Apple keyboards: Command → Ctrl, Option stays Alt; use Control key for Activities.
# Remove this file and run: sudo systemctl restart keyd  to disable.
# See: https://github.com/rvaiya/keyd/blob/master/docs/examples.md

[ids]
*

[main]
leftmeta = leftcontrol
leftcontrol = leftmeta
rightmeta = rightcontrol
rightcontrol = rightmeta
KEYDEOF
sudo systemctl enable --now keyd

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

echo "==> WhiteSur GTK theme (includes GNOME Shell assets; --libadwaita for GTK4 / libadwaita apps)"
cd "$HOME"
rm -rf WhiteSur-gtk-theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
(
  cd WhiteSur-gtk-theme
  ./install.sh --libadwaita
)

echo "==> WhiteSur icon theme"
rm -rf WhiteSur-icon-theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
(
  cd WhiteSur-icon-theme
  ./install.sh
)

echo "==> Apply WhiteSur-Dark (GTK, icons, shell, mac-like window controls)"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark" || true

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
echo "  1. Log out and back in (themes, extensions, and keyd apply cleanly after a fresh session)."
echo "  2. If shell theme is still default: open Extension Manager → enable User Themes → set shell to WhiteSur-Dark in Tweaks."
echo "  3. Run: sudo tailscale up"
echo "  4. If keyd is wrong for your keyboard (e.g. PC layout), remove /etc/keyd/default.conf and: sudo systemctl restart keyd"
