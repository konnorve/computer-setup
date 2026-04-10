# computer-setup

One-command bootstrap for a fresh machine on **macOS** or **Ubuntu**. macOS installs Homebrew, apps, CLI tools, Miniforge, and conda environments; Ubuntu installs desktop apps, themes, and tools via `apt`/`snap`.

## macOS — Quick Start

```bash
# Default profile (all)
bash <(curl -fsSL https://raw.githubusercontent.com/konnorve/computer-setup/main/main.sh)

# Or specify a profile
bash <(curl -fsSL https://raw.githubusercontent.com/konnorve/computer-setup/main/main.sh) lean
```

Homebrew may prompt for your sudo password during installation.

## Ubuntu — Quick Start

Assumes `curl` is already installed. The script uses `sudo` and targets a typical **Ubuntu Desktop** (GNOME) session.

```bash
curl -fsSL https://raw.githubusercontent.com/konnorve/computer-setup/main/ubuntu.sh | bash
```

| Profile | What it installs |
|---------|-----------------|
| **all** (default) | Spotify, Notion, Firefox, Slack, VS Code, Office, Rectangle, 1Password, Cursor, Zoom, wget, tree, imagemagick |
| **lean** | Firefox, 1Password, Zoom |

After the Brewfile, the script installs [Miniforge](https://github.com/conda-forge/miniforge) (mamba/conda) and creates the `analysis` conda environment.

## What it does

1. Installs **Homebrew** (skipped if already present)
2. Installs packages from the selected **Brewfile** profile
3. Installs **Miniforge** via the official installer (skipped if already present)
4. Runs `mamba init` for zsh and bash
5. Creates the **analysis** conda environment from `analysis.yaml`

## Ubuntu: what `ubuntu.sh` does

Installs base packages (`apt`), VS Code and Firefox (`snap`), 1Password, Tailscale, Spotify, WhiteSur GTK/icon themes, and the Blur My Shell GNOME extension. You may need to log out and back in, then run `sudo tailscale up`.

## Files

```
main.sh              # macOS setup script (entry point)
ubuntu.sh            # Ubuntu setup script (apt/snap, GNOME themes)
all.Brewfile         # Full Homebrew bundle
lean.Brewfile        # Minimal Homebrew bundle
analysis.yaml        # Conda environment definition
```

## Requirements

**macOS**

- Apple Silicon or Intel
- Internet connection

**Ubuntu**

- Desktop install with GNOME (for theme/extension steps)
- Internet connection
