#!/bin/bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/konnorve/mac-setup/main"

# ---------------------------------------------------------------------------
# Profile selection
# ---------------------------------------------------------------------------
echo ""
echo "Select a Brewfile profile:"
echo "  1) all           - Full setup (apps, CLI tools)"
echo "  2) lean          - Minimal (Firefox, 1Password, Zoom)"
echo "  3) probe_wizard  - Dev tools (VS Code, Cursor, Office)"
echo ""
read -r -p "Enter choice [1]: " choice </dev/tty

case "${choice:-1}" in
  1) PROFILE="all.Brewfile" ;;
  2) PROFILE="lean.Brewfile" ;;
  3) PROFILE="probe_wizard.brewfile" ;;
  *) echo "Invalid choice, defaulting to 'all'." ; PROFILE="all.Brewfile" ;;
esac

echo "=> Using profile: $PROFILE"
echo ""

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
