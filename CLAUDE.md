# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Declarative development environment for team Aplicações using Nix flakes and Home Manager. Replaces the imperative onboarding process (SDKMAN, NVM, manual apt installs) with reproducible, per-user configurations.

Language versions (Java, Node, etc.) are NOT managed here — they belong in per-project `devenv.nix` files. This repo provides the base tooling every developer needs.

## Architecture

```
flake.nix                       # Entry point, user list, three nixpkgs channels
home.nix                        # Base config for ALL users (packages + module imports)
modules/
  npmrc.nix                     # Deploys .npmrc template via activation (won't overwrite)
users/{username}/
  default.nix                   # User entry point (imports pkgs.nix)
  pkgs.nix                      # User-specific package additions
```

**Three nixpkgs channels** available in all modules:
- `pkgs` — stable (nixos-25.05), default choice
- `pkgsUnstable` — nixos-unstable
- `pkgsLatest` — independently pinned bleeding edge (`nix flake update nixpkgs-latest`)

**Module pattern**: modules use `home.activation` for one-time file deployments (copy if not exists) rather than `home.file` symlinks, so users can modify files locally after initial setup.

## Commands

```bash
# Apply configuration
nix run home-manager -- switch --flake .#username@x86_64-linux

# Dry build (test without activating)
nix build .#homeConfigurations.username@x86_64-linux.activationPackage

# Format nix files
alejandra .

# Update all inputs
nix flake update

# Update only bleeding edge packages
nix flake update nixpkgs-latest
```

## Adding a User

1. Add `{ username = "name"; }` to the `users` list in `flake.nix`
2. Create `users/name/default.nix` importing `./pkgs.nix`
3. Create `users/name/pkgs.nix` with user-specific packages
4. Run `nix run home-manager -- switch --flake .#name@x86_64-linux`

## Per-Project Dev Environments

Projects use `devenv.nix` for language-specific tooling. Common patterns from existing repos:

```nix
# Java + Maven project (e.g., api-opera, api-autorizacoes)
{ pkgs, ... }: {
  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk21;  # or pkgs.jdk8
    maven.enable = true;
  };
  cachix.enable = false;
}

# Node.js project (e.g., app-aplicacoes)
{ pkgs, ... }: {
  packages = with pkgs; [ nodejs_20 yarn ];
  cachix.enable = false;
}
```

Activate with `devenv shell` or automatically via `direnv` (add `devenv` to `.envrc`).
