# Cheat Engine Flake

[![Cheat Engine](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fcheatengine-flake%2Fmain%2Fversion.json&query=%24.version&label=cheatengine&color=5c2d91&link=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fcheatengine-flake%2Fmain%2Fversion.json)](https://cheatengine.org/downloads.php)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/cheatengine-flake/update.yml?branch=main&label=auto-update)](https://github.com/Hy4ri/cheatengine-flake/actions/workflows/update.yml)

Nix flake for [Cheat Engine](https://cheatengine.org) — a memory scanner and debugger for Linux.

## Installation

### Try it out

```bash
nix run github:Hy4ri/cheatengine-flake
```

### NixOS / Home Manager

1. Add the flake input:

```nix
{
  inputs.cheatengine.url = "github:Hy4ri/cheatengine-flake";
}
```

2. Add the overlay:

```nix
nixpkgs.overlays = [ inputs.cheatengine.overlays.default ];
```

3. Install the package:

```nix
# NixOS
environment.systemPackages = with pkgs; [
  cheatengine
];

# Home Manager
home.packages = with pkgs; [
  cheatengine
];
```

## Project Structure

| File | Purpose |
|---|---|
| `flake.nix` | Flake entry point — exposes package and overlay |
| `package.nix` | Derivation — downloads, patches, and installs Cheat Engine |
| `update-version.sh` | CLI tool to update version and hash: `./update-version.sh 7.7` |
| `version.json` | Version metadata (used by README badge) |
| `flake.lock` | Pinned nixpkgs revision |

## Manual Updates

If a new Cheat Engine release is out and the auto-update CI hasn't caught it yet:

```bash
./update-version.sh 7.8
```

The script will:
1. Download the `.zip` file
2. Calculate its `sha256` hash
3. Update the version and hash in `package.nix`
4. Update `version.json` and README badge link

## Local Development

```bash
# Evaluate the flake
nix flake check

# Build
nix build .#cheatengine

# Run directly (no install)
nix run .#cheatengine
```
