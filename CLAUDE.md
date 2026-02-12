# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Declarative development environment for team Aplicações using Nix flakes and Home Manager. Each developer forks this repo and customizes their own packages. Language versions (Java, Node, etc.) belong in per-project `devenv.nix` files — this repo provides base tooling.

## Architecture

```
flake.nix          # Entry point, three nixpkgs channels, username from $USER
home.nix           # All packages and module imports
modules/
  npmrc.nix        # Deploys .npmrc template via activation (won't overwrite)
```

**Three nixpkgs channels** available:
- `pkgs` — stable (nixos-25.05), default choice
- `pkgsUnstable` — nixos-unstable
- `pkgsLatest` — independently pinned bleeding edge (`nix flake update nixpkgs-latest`)

**Module pattern**: `home.activation` for one-time file deployments (copy if not exists), not `home.file` symlinks — users can modify files locally after initial setup.

## Commands

```bash
# Apply configuration (--impure needed for $USER detection)
nix run home-manager -- switch --flake .#default --impure

# Dry build
nix build .#homeConfigurations.default.activationPackage --impure

# Format nix files
alejandra .

# Update all inputs
nix flake update

# Update only bleeding edge packages
nix flake update nixpkgs-latest
```

## Per-Project Dev Environments

Projects use `devenv.nix` for language-specific tooling:

```nix
# Java + Maven (e.g., api-opera, api-autorizacoes)
{ pkgs, ... }: {
  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk21;  # or pkgs.jdk8
    maven.enable = true;
  };
  cachix.enable = false;
}

# Node.js (e.g., app-aplicacoes)
{ pkgs, ... }: {
  packages = with pkgs; [ nodejs_20 yarn ];
  cachix.enable = false;
}
```

Activate with `devenv shell` or automatically via `direnv`.
