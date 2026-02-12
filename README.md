# Aplicacoes Team - Development Environment

Declarative development environment for team Aplicacoes using Nix flakes and Home Manager. Each developer forks this repo and customizes their own packages. 

## Quick Start

### 1. Install Nix

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 2. Clone and apply

```bash
git clone <repository-url> ~/aplicacoes-env
cd ~/aplicacoes-env
git config core.hooksPath .githooks
make switch
```

### 3. Per-project environments

Language tooling lives in each project's `devenv.nix`, not here:

```nix
# Java + Maven
{ pkgs, ... }: {
  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk21;
    maven.enable = true;
  };
  cachix.enable = false;
}

# Node.js
{ pkgs, ... }: {
  packages = with pkgs; [ nodejs_20 yarn ];
  cachix.enable = false;
}
```

Activate with `devenv shell`.

## What's Included

### Packages

- **Core:** git (with delta pager), curl, ripgrep-all, xclip, zip/unzip
- **Cloud/K8s:** awscli2, kubectl, k9s, docker-compose
- **Dev Tools:** devenv, direnv, uv, insomnia, postman, redisinsight
- **Nix Tooling:** alejandra, nixd, nixfmt-rfc-style, agenix

### Modules

| Module | What it does |
|--------|-------------|
| `git.nix` | `programs.git` with delta pager, betha email, rebase on pull |
| `ssh.nix` | SSH matchBlocks for gitlab.services.betha.cloud and github.com |
| `shell.nix` | EKS aliases (`eks-login`, `eks-test`, `eks-prod`), `~/.local/bin` in PATH |
| `npmrc.nix` | Deploys `.npmrc` with nexus registry on first activation |
| `agenix.nix` | Encrypted secrets decrypted at login via systemd user service |

### Three Package Channels

| Channel | Source | When to use |
|---------|--------|-------------|
| `pkgs` | nixos-25.05 | Default choice for most packages |
| `pkgsUnstable` | nixos-unstable | When stable is too old |
| `pkgsLatest` | Independently pinned | Bleeding edge (`nix flake update nixpkgs-latest`) |

## Secrets Management

Encrypted secrets via [agenix](https://github.com/ryantm/agenix). Secrets are decrypted by a systemd user service at login, not during `home-manager switch`.

**Current secrets:** `npm-auth-token`, `gitlab-deploy-token`, `aws-credentials`

### How it works

1. `secrets/secrets.nix` lists public keys authorized to decrypt each secret
2. `secrets/*.age` are age-encrypted files committed to git
3. At login, `agenix.service` decrypts to `$XDG_RUNTIME_DIR/agenix/`
4. `inject-npm-auth.service` runs after agenix to append `_authToken` to `.npmrc`

### Adding a new secret

```bash
agenix -e secrets/new-secret.age
```

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

Direct nix commands:

```bash
nix run home-manager -- switch --flake .#"$USER@x86_64-linux" --impure
nix build .#homeConfigurations."$USER@x86_64-linux".activationPackage --impure --no-link
nix flake update
nix flake update nixpkgs-latest
```

## Pre-Push Checks

Configured via `.githooks/pre-push.sh`:

Skip with `SKIP_HOOKS=1 git push`.

## Consuming as Home Manager Module

This flake exposes `homeManagerModules` for use in personal dotfiles:

```nix
# In your flake.nix inputs:
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

The consuming flake must provide `pkgs`, `pkgsUnstable`, `pkgsLatest`, `version`, `inputs`, and `username` via `extraSpecialArgs`.
