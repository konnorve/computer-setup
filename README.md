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

**Profiles (`all` / `lean`) are macOS only.** They choose which Brewfile `main.sh` uses. Ubuntu has a single script (`ubuntu.sh`) with no profile flag.

| Profile | What it installs (macOS) |
|---------|--------------------------|
| **all** (default) | Spotify, Notion, Firefox, Slack, VS Code, Office, Rectangle, 1Password, Cursor, Zoom, wget, tree, imagemagick |
| **lean** | Firefox, 1Password, Zoom |

After the Brewfile, the macOS script installs [Miniforge](https://github.com/conda-forge/miniforge) (mamba/conda) and creates the `analysis` conda environment.

## macOS: what `main.sh` does

1. Installs **Homebrew** (skipped if already present)
2. Installs packages from the selected **Brewfile** profile (`all` or `lean`)
3. Installs **Miniforge** via the official installer (skipped if already present)
4. Runs `mamba init` for zsh and bash
5. Creates the **analysis** conda environment from `analysis.yaml`

## Ubuntu — Quick Start

Assumes `curl` is already installed. The script uses `sudo` and targets a typical **Ubuntu Desktop** (GNOME) session.

```bash
curl -fsSL https://raw.githubusercontent.com/konnorve/computer-setup/main/ubuntu.sh | bash
```

## Ubuntu: what `ubuntu.sh` installs

There is no `all`/`lean` switch on Ubuntu—everything below is installed every time.

**APT**

| Package | Role |
|---------|------|
| `ca-certificates`, `curl`, `git`, `gpg`, `make`, `wget` | Core tooling |
| `tree` | Directory listing |
| `imagemagick` | Image conversion / CLI |
| `inkscape` | Vector graphics |
| `libreoffice` | Office suite |

**`.deb` (downloaded)**

| Item | Role |
|------|------|
| **1Password** | Password manager (official Linux `.deb`) |

**Snap**

| Package | Role |
|---------|------|
| **code** | Visual Studio Code |
| **firefox** | Browser |
| **spotify** | Music |
| **notion-desktop** | Notion (community-maintained Linux desktop client; not published by Notion) |
| **zoom-client** | Zoom meetings |

**Other**

| Item | Role |
|------|------|
| **Tailscale** | VPN/mesh (`tailscale.com/install.sh`) |
| **WhiteSur GTK + icon themes** | Cloned from GitHub, run each theme’s `install.sh`, then `gsettings` to **WhiteSur-Dark** |
| **Blur My Shell** | GNOME extension (`make install` from cloned repo; extension enabled if possible) |

Afterward, log out and back in if themes or the extension do not apply, then run `sudo tailscale up`.

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
