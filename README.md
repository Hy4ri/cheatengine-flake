# Cheat Engine Flake

[![Cheat Engine](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fcheatengine-flake%2Fmain%2Fversion.json&query=%24.version&label=cheatengine&color=5c2d91&link=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fcheatengine-flake%2Fmain%2Fversion.json)](https://cheatengine.org/downloads.php)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/cheatengine-flake/update.yml?branch=main&label=auto-update)](https://github.com/Hy4ri/cheatengine-flake/actions/workflows/update.yml)

Run and install [Cheat Engine](https://cheatengine.org) for Linux on NixOS, Home Manager, or any Linux system with Nix.

Cheat Engine is a memory scanner and debugger. You can use it to find and change values in running programs and games.

The flake is updated automatically every day.

## Packages

| Package | What it is | Command |
|---|---|---|
| `cheatengine` (default) | Cheat Engine for Linux | `cheatengine` |

Platforms: Linux `x86_64` only.

## Try it without installing

You need Nix with [flakes enabled](https://wiki.nixos.org/wiki/Flakes).

```bash
nix run github:Hy4ri/cheatengine-flake
```

## Install

There are **two ways** to install. **Pick one.** They give the same result.

| Option | Use it when |
|---|---|
| **A. Overlay** | You want to write `pkgs.cheatengine`, like any other nixpkgs package. |
| **B. Direct package** | You do not want to use overlays. |

### Step 1: Add the flake input (needed for both options)

In your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cheatengine.url = "github:Hy4ri/cheatengine-flake";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # lets your modules use `inputs`
      modules = [ ./configuration.nix ];
    };
  };
}
```

> Already have a flake? Add only the `cheatengine.url` line, and make sure `inputs` reaches your modules (`specialArgs` for NixOS, `extraSpecialArgs` for Home Manager).

### Step 2, Option A: Overlay

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.cheatengine.overlays.default ];
  nixpkgs.config.allowUnfree = true; # required: the package is marked unfree

  environment.systemPackages = [ pkgs.cheatengine ];
}
```

For Home Manager, keep the two `nixpkgs` lines and use `home.packages = [ pkgs.cheatengine ];` instead.

### Step 2, Option B: Direct package

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.cheatengine.packages.${pkgs.stdenv.hostPlatform.system}.cheatengine
  ];
}
```

You do not need `allowUnfree` for this option. For Home Manager, put the same line in `home.packages`.

### Step 3: Rebuild

```bash
sudo nixos-rebuild switch --flake .#myhost
```

## Updates

A GitHub Action checks for new Cheat Engine releases every day, tests the build, and commits the new version. To get it, update your lock file:

```bash
nix flake update cheatengine
```

### Manual update (maintainers)

If a new release is out and the daily job has not found it yet:

```bash
./update-version.sh 7.8
```

The script downloads the `.zip`, computes its hash, and updates `package.nix` and `version.json`.

### Repository layout

| File | Purpose |
|---|---|
| `flake.nix` | Flake entry point: package and overlay |
| `package.nix` | Downloads, patches, and installs Cheat Engine |
| `update-version.sh` | Updates the version and hash |
| `version.json` | Current version (also used by the badge) |

Local checks: `nix flake check` and `nix build .#cheatengine`.

## License

This flake packaging is provided under the [MIT license](LICENSE). Cheat Engine itself has its own license terms; Nix marks it as unfree. This flake only downloads and packages the official release.

## Support

If this flake helps you, you can support my work on [GitHub Sponsors](https://github.com/sponsors/hy4ri) or [Ko-fi](https://ko-fi.com/m_5_7). A star on the repo also helps.
