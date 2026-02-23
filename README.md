# Aplicacoes Team - Development Environment

Declarative development environment for team Aplicacoes using Nix flakes and Home Manager. Forget everything you know about Nix — this is just a framework to configure apps and dotfiles. Each developer forks this repo and customizes their own packages.

The entrypoint is `flake.nix`. It defines inputs (where packages come from), outputs (the home configuration applied to your user), and reusable modules for external consumption. Read it top to bottom — it is commented to explain every section.

## Quick Start

### 1. Install Nix

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 2. Clone and apply

```bash
git clone https://github.com/Castrozan/aplicacoes-env ~/aplicacoes-env
cd ~/aplicacoes-env
git config core.hooksPath .githooks
make switch
```

`make switch` detects the current system and runs `nix run home-manager -- switch --flake .#"$USER@$SYSTEM" --impure`. The `--impure` flag is required because `flake.nix` uses `builtins.getEnv "USER"` and `builtins.currentSystem` to auto-detect the current username and system architecture at evaluation time. This means the same flake works on both Linux (`x86_64-linux`) and macOS (`aarch64-darwin`, `x86_64-darwin`) without changes. On macOS, linux-only packages like `xclip` are excluded and systemd services are skipped.

## How it works

`flake.nix` declares three sections:

**Inputs** fetch package definitions and modules from the internet. There are three package channels — `nixpkgs` (stable, nixos-25.05) for most packages, `nixpkgs-unstable` for packages not yet in stable, and `nixpkgs-latest` for bleeding edge (update independently with `nix flake update nixpkgs-latest`). Home Manager and agenix are also declared as inputs, both following the same nixpkgs to avoid duplicate evaluations.

**Outputs** define what this flake provides. The main output is a `homeConfigurations` entry that builds a standalone Home Manager configuration for the current user. It composes three module files: `home/core.nix` (username, home directory, state version), `home/pkgs.nix` (all installed packages), and `home/modules.nix` (imports everything from `home/modules/`). All modules receive shared variables (`pkgs`, `pkgsLatest`, `version`, `inputs`, `username`) via dependency injection through `specialArgs`.

**homeManagerModules** expose individual pieces for consumption by personal dotfiles flakes — you can import packages only, modules only, secrets only, or the default (packages + modules).

## Modules

Modules live in `home/modules/`. Each one configures a specific tool or service using a copy-if-not-exists pattern via `home.activation` — files are deployed on first activation but never overwritten, so users can modify them locally after setup.

| Module | What it does |
|--------|-------------|
| `git.nix` | `.gitconfig` with delta pager, betha email, rebase on pull |
| `ssh.nix` | `~/.ssh/config` for gitlab.services.betha.cloud and github.com |
| `shell.nix` | `programs.bash` with history config, team aliases (eza, bat, k9s, EKS), PATH additions, `~/.bashrc.local` sourcing |
| `npmrc.nix` | `.npmrc` with nexus registry, plus `inject-npm-auth` systemd service for token injection |
| `agenix.nix` | Encrypted secrets decrypted at login via systemd user service |

## Secrets Management

Encrypted secrets via [agenix](https://github.com/ryantm/agenix). The agenix Home Manager module runs a systemd user service at login (not during `home-manager switch`) that decrypts `.age` files to `$XDG_RUNTIME_DIR/agenix/`. The `inject-npm-auth` service runs after agenix to append `_authToken` to `.npmrc`.

`secrets/secrets.nix` lists which public keys can decrypt each secret. To add a new secret: `agenix -e secrets/new-secret.age`.

## Commands

```bash
make switch       # Apply config to current user
make test         # Run all tests (eval + full deployment)
make test-eval    # Quick: flake evaluation only
make test-full    # Full: home-manager activation on Ubuntu 24.04
make shell        # Interactive debug container
make lint         # statix + deadnix + nixfmt check
make fmt          # Format nix files
```

## Consuming as Home Manager Module

This flake exposes `homeManagerModules` for use in personal dotfiles:

```nix
# In your flake.nix inputs:
aplicacoes-env.url = "github:Castrozan/aplicacoes-env";

# In your home-manager modules:
imports = [ inputs.aplicacoes-env.homeManagerModules.default ];

# Or import selectively:
imports = [
  inputs.aplicacoes-env.homeManagerModules.packages  # only packages
  inputs.aplicacoes-env.homeManagerModules.modules    # only modules (git, ssh, shell, npmrc, agenix)
  inputs.aplicacoes-env.homeManagerModules.secrets    # only agenix secrets config
];
```

The consuming flake must provide `pkgs`, `pkgsLatest`, `version`, `inputs`, and `username` via `extraSpecialArgs`.

## Pre-Push Checks

Configured via `.githooks/pre-push.sh`. Skip with `SKIP_HOOKS=1 git push`.
