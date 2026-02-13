#!/bin/bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/konnorve/mac-setup/main"

# ---------------------------------------------------------------------------
# Profile selection (via argument; defaults to "all")
# ---------------------------------------------------------------------------
case "${1:-all}" in
  all)  PROFILE="all.Brewfile" ;;
  lean) PROFILE="lean.Brewfile" ;;
  *)
    echo "Usage: $0 [all|lean]"
    exit 1
    ;;
esac

echo "=> Using profile: $PROFILE"
echo ""

# ---------------------------------------------------------------------------
# Acquire sudo up front and keep it alive for the duration of the script
# ---------------------------------------------------------------------------
echo "Sudo access is required for Homebrew installation."
sudo -v
# Refresh sudo timestamp in the background until this script exits.
while true; do sudo -n true; sleep 50; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed."
fi

# Ensure brew is on PATH (Apple Silicon: /opt/homebrew, Intel: /usr/local)
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null \
  || /usr/local/bin/brew shellenv 2>/dev/null)"

echo "Installing packages from ${PROFILE}..."
curl -fsSL "${REPO_URL}/${PROFILE}" | brew bundle --file=-

# ---------------------------------------------------------------------------
# Miniforge (mamba)
# ---------------------------------------------------------------------------
if ! command -v mamba &>/dev/null; then
  echo "Installing Miniforge..."
  MINIFORGE="Miniforge3-$(uname)-$(uname -m).sh"
  curl -fsSL -o "/tmp/${MINIFORGE}" \
    "https://github.com/conda-forge/miniforge/releases/latest/download/${MINIFORGE}"
  bash "/tmp/${MINIFORGE}" -b
  rm -f "/tmp/${MINIFORGE}"
else
  echo "Miniforge already installed."
fi

# Activate conda/mamba in this shell session
eval "$("${HOME}/miniforge3/bin/conda" shell.bash hook)"

# Persist init for future shells
mamba init zsh bash

# ---------------------------------------------------------------------------
# Conda environments
# ---------------------------------------------------------------------------
echo "Creating conda environments..."
curl -fsSL "${REPO_URL}/analysis.yaml" -o /tmp/analysis.yaml
mamba env create --file /tmp/analysis.yaml -y
rm -f /tmp/analysis.yaml

echo ""
echo "Done! Restart your terminal to apply shell changes."
