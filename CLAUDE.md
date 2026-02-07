# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository manages development environment configurations for the Aplicações team using Nix and Home Manager. It provides declarative, reproducible user environments with shared base packages and user-specific customizations.

## Architecture

The configuration uses a **multi-user pattern** where each team member gets their own isolated Home Manager configuration while sharing common packages and modules.

### Key Components

- **`flake.nix`**: Entry point that orchestrates everything
  - Defines three nixpkgs inputs: stable (25.05), unstable, and latest
  - Contains a `users` list where team members are registered
  - Generates a homeConfiguration for each user in the format `username@x86_64-linux`
  - Makes all three package sets available as `pkgs`, `pkgsUnstable`, and `pkgsLatest`

- **`home.nix`**: Base configuration applied to ALL users
  - Imports shared modules (pipx, sdkman)
  - Defines common packages used by the entire team
  - Sets up home-manager basics (username, homeDirectory)

- **`users/{username}/`**: User-specific configurations
  - `default.nix`: Entry point that imports user-specific modules
  - `pkgs.nix`: Additional packages for this specific user
  - Users can override or extend the base configuration here

- **`modules/`**: Reusable configuration modules
  - `pipx.nix`: Python package manager setup with PATH configuration
  - `sdkman.nix`: JVM tooling manager (installs via activation script)
  - `m2.nix`: Maven configuration (currently commented out in home.nix)

- **`dotfiles/`**: Configuration files symlinked into user homes
  - `.m2/`: Maven settings template

### Package Selection Strategy

Use the appropriate package set based on stability needs:
- `pkgs`: Stable packages from nixos-25.05 (default choice)
- `pkgsUnstable`: Newer packages from nixos-unstable
- `pkgsLatest`: Bleeding edge packages (manually updated via `nix flake update nixpkgs-latest`)

## Common Commands

### Building and Activating

Build and activate a user's configuration:
```bash
nix run home-manager -- switch --flake .#username@x86_64-linux
```

Build without activating (useful for testing):
```bash
nix build .#homeConfigurations.username@x86_64-linux.activationPackage
```

### Managing Users

1. Add a new user to the `users` list in `flake.nix`:
```nix
users = [
  { username = "lucas.zanoni"; }
  { username = "new.user"; }
];
```

2. Create their user directory:
```bash
mkdir -p users/new.user
```

3. Create `users/new.user/default.nix`:
```nix
{ ... }:
{
  imports = [
    ./pkgs.nix
  ];
}
```

4. Create `users/new.user/pkgs.nix` for user-specific packages

### Formatting

Format all Nix files using the project's standard formatter:
```bash
alejandra .
```

Alternative formatters available: `nixfmt-rfc-style`, `nixd`

### Updating Dependencies

Update all flake inputs:
```bash
nix flake update
```

Update only the latest packages:
```bash
nix flake update nixpkgs-latest
```

## Module Development

When creating new modules in `modules/`:

- **For simple package additions**: Just add packages to a list (see `pipx.nix`)
- **For tools requiring installation scripts**: Use `home.activation` (see `sdkman.nix`)
- **For dotfile management**: Use `home.file.{name}.source` to symlink files (see `m2.nix`)

All modules receive standard arguments: `pkgs`, `pkgsUnstable`, `pkgsLatest`, `username`, `inputs`

After creating a module, import it in either:
- `home.nix` (for all users)
- `users/{username}/default.nix` (for specific users)

## Important Notes

- The m2 module is currently commented out in `home.nix` (line 15)
- All configurations target `x86_64-linux` architecture
- Unfree packages are allowed via `config.allowUnfree = true`
- Home Manager news display is silenced via `news.display = "silent"`
