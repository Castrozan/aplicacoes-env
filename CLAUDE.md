# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Declarative development environment for team Aplicações using Nix flakes and Home Manager. Each developer forks this repo and customizes their own packages. Language versions (Java, Node, etc.) belong in per-project `devenv.nix` files — this repo provides base tooling.

## Architecture

```
flake.nix              # Entry point, nixpkgs channels, $USER detection
home/
  core.nix             # Home Manager basics (username, homeDirectory, stateVersion)
  pkgs.nix             # All directly installed packages
  modules.nix          # Imports all modules from home/modules/
  modules/
    npmrc.nix          # Deploys .npmrc via activation (won't overwrite existing)
tests/
  Dockerfile           # Quick eval test (Ubuntu 24.04 + Nix)
  Dockerfile.full      # Full deployment test (home-manager activation)
  test-nix.sh          # Test runner script
docker-compose.yml     # Test service definitions
Makefile               # make test, make lint, make switch, etc.
.githooks/
  pre-push.sh          # statix, deadnix, nixfmt, build check
```

**Three nixpkgs channels** available via `specialArgsBase`:
- `pkgs` — stable (nixos-25.05), default choice
- `pkgsUnstable` — nixos-unstable
- `pkgsLatest` — independently pinned bleeding edge (`nix flake update nixpkgs-latest`)

**Module pattern**: `home.activation` for one-time file deployments (copy if not exists), not `home.file` symlinks — users can modify files locally after initial setup.

## Commands

```bash
# Apply configuration (--impure needed for $USER detection)
nix run home-manager -- switch --flake .#"$USER@x86_64-linux" --impure

# Dry build
nix build .#homeConfigurations."$USER@x86_64-linux".activationPackage --impure --no-link

# Format nix files
alejandra .

# Update all inputs
nix flake update

# Update only bleeding edge packages
nix flake update nixpkgs-latest
```

## Testing

Two-tier Docker testing strategy (same pattern as openclaw-aplicacoes):

```bash
make test-eval    # Quick: flake evaluation only (fast)
make test-full    # Full: home-manager activation on Ubuntu 24.04
make test         # Both
make shell        # Interactive debug container
make lint         # statix + deadnix + nixfmt check
make fmt          # Format nix files
make switch       # Apply config to current user
```

## Pre-Push Checks

Configured via `.githooks/pre-push.sh` (set `core.hooksPath` after cloning):

```bash
git config core.hooksPath .githooks
```

Checks: `statix`, `deadnix`, `nixfmt-rfc-style --check`, and a `nix build` validation. Skip with `SKIP_HOOKS=1`.

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
