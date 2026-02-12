# Goals

## Problem

Onboarding new developers to team Aplicacoes relies on a wiki with imperative steps: install SDKMAN, NVM, manually apt-install packages, configure git, set up SSH keys, copy .npmrc. This is error-prone, drifts over time, and every machine ends up slightly different.

## Solution

Replace the imperative onboarding with a single declarative Nix flake. A new developer forks this repo, runs `make switch`, and gets the full team-standard environment.

## Principles

- **Fork and customize.** Each developer owns their fork. The base config provides team standards; individuals add or remove packages as they see fit.
- **Reproducible.** Pinned nixpkgs channels ensure every machine gets the same versions. Three channels (stable, unstable, latest) give flexibility without sacrificing reproducibility.
- **Files belong to the user.** `home.activation` copies files on first run, then the user can edit them freely. No symlink management fighting local changes.
- **Declarative over imperative.** No SDKMAN, no NVM, no manual apt installs. Everything managed by Nix and Home Manager.
- **Base tooling only.** Language versions (Java, Node) belong in per-project `devenv.nix` files, not here. This repo provides what every developer needs regardless of which project they're working on.
