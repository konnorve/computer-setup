# mac-setup

One-command bootstrap for a fresh macOS machine. Installs Homebrew, apps, CLI tools, Miniforge, and conda environments.

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/konnorve/mac-setup/main/main.sh)
```

You'll be prompted to choose a profile:

| # | Profile | What it installs |
|---|---------|-----------------|
| 1 | **all** | Spotify, Notion, Firefox, Slack, VS Code, Office, Rectangle, 1Password, Cursor, Zoom, wget, tree, imagemagick |
| 2 | **lean** | Firefox, 1Password, Zoom |
| 3 | **probe_wizard** | VS Code, Office, Cursor, tree |

After the Brewfile, the script installs [Miniforge](https://github.com/conda-forge/miniforge) (mamba/conda) and creates the `analysis` conda environment.

## What it does

1. Installs **Homebrew** (skipped if already present)
2. Installs packages from the selected **Brewfile** profile
3. Installs **Miniforge** via the official installer (skipped if already present)
4. Runs `mamba init` for zsh and bash
5. Creates the **analysis** conda environment from `analysis.yaml`

## Files

```
main.sh              # Setup script (entry point)
all.Brewfile          # Full Homebrew bundle
lean.Brewfile         # Minimal Homebrew bundle
probe_wizard.brewfile # Dev-focused Homebrew bundle
analysis.yaml        # Conda environment definition
```

## Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
