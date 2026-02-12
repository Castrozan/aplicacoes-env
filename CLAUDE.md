# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Declarative development environment for team Aplicações using Nix flakes and Home Manager. Each developer forks this repo and customizes their own packages. Language versions (Java, Node, etc.) belong in per-project `devenv.nix` files — this repo provides base tooling.

## Architecture

```
flake.nix              # Entry point, nixpkgs channels, $USER detection, homeManagerModules
home/
  core.nix             # Home Manager basics (username, homeDirectory, stateVersion)
  pkgs.nix             # All directly installed packages
  modules.nix          # Imports all modules from home/modules/
  modules/
    agenix.nix         # Encrypted secrets (age.identityPaths, age.secrets)
    git.nix            # programs.git with delta pager, betha email
    npmrc.nix          # Deploys .npmrc via activation + auth token injection service
    shell.nix          # EKS aliases, session variables, PATH
    ssh.nix            # SSH matchBlocks for gitlab/github
secrets/
  secrets.nix          # Public key registry for agenix
  *.age                # Encrypted secret files
tests/
  Dockerfile           # Quick eval test (Ubuntu 24.04 + Nix)
  Dockerfile.full      # Full deployment test (home-manager activation + agenix)
  test-key / test-key.pub  # CI-only test keypair (no security value)
  encrypt-test-secrets.sh  # Regenerate test .age files
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

## Secrets Management (agenix)

Encrypted secrets via [agenix](https://github.com/ryantm/agenix) using `agenix.homeManagerModules.default`. Secrets are decrypted by a **systemd user service** at login, not during `home-manager switch`.

**Current secrets**: `npm-auth-token`, `gitlab-deploy-token`, `aws-credentials`

**How it works**:
- `secrets/secrets.nix` lists public keys that can encrypt/decrypt each secret
- `secrets/*.age` are age-encrypted files (committed to git)
- `home/modules/agenix.nix` defines `age.identityPaths` and `age.secrets`
- At login, `agenix.service` decrypts to `$XDG_RUNTIME_DIR/agenix/`
- `inject-npm-auth.service` runs after agenix to append `_authToken` to `.npmrc`

**Adding a new secret**:
```bash
agenix -e secrets/new-secret.age
```

**Re-keying after adding/removing a user key**:
1. Update `secrets/secrets.nix` with the new key
2. Run `agenix -r` from the repo root (requires one existing authorized key)

**Adding a new team member**:
1. Get their SSH ed25519 public key
2. Add to `secrets/secrets.nix`
3. Re-key: `agenix -r`

**CI test key**: `tests/test-key` is a committed ephemeral keypair with no security value — it only decrypts test placeholder values for Docker CI verification.

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

## Consuming as Home Manager Module

This flake exposes `homeManagerModules` for use in personal dotfiles:

```nix
# In your personal flake.nix inputs:
aplicacoes-env.url = "github:your-org/aplicacoes-env";

# In your home-manager modules:
imports = [ inputs.aplicacoes-env.homeManagerModules.default ];

# Or import selectively:
imports = [
  inputs.aplicacoes-env.homeManagerModules.packages  # only packages
  inputs.aplicacoes-env.homeManagerModules.modules    # only modules (git, ssh, shell, npmrc, agenix)
  inputs.aplicacoes-env.homeManagerModules.secrets    # only agenix secrets config
];
```

Modules receive `pkgs`, `pkgsUnstable`, `pkgsLatest`, `version`, `inputs`, and `username` via `extraSpecialArgs` — the consuming flake must provide these.
