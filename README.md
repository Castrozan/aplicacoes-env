# Aplicações Team - Development Environment

<p align="center">
  <a href="https://github.com/castrozan/aplicacoes-env/actions/workflows/ci.yml">
    <img alt="CI" src="https://img.shields.io/github/actions/workflow/status/castrozan/aplicacoes-env/ci.yml?style=for-the-badge&logo=github-actions">
  </a>
  <a href="https://nixos.org/">
    <img src="https://img.shields.io/badge/NixOS-25.05-informational.svg?style=for-the-badge&logo=nixos">
  </a>
</p>

Declarative development environment configuration for the Aplicações team using Nix and Home Manager. Share common tools while maintaining individual customizations.

## 🚀 Quick Start

### For Team Members

If you're a team member getting set up:

#### 1. Install Nix (if not already installed)
```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

#### 2. Clone this repository
```bash
cd ~
git clone <repository-url>
cd aplicacoes-env
```

#### 3. Ask a team lead to add your user configuration
Your configuration will be in `users/your.name/`

#### 4. Build and activate your environment
```bash
# Using make (recommended)
make switch USER=your.name

# Or directly with nix
nix run home-manager -- switch --flake .#your.name@x86_64-linux
```

### For Team Leads

#### Adding a new team member:

1. **Add user to the list in `flake.nix`:**
```nix
users = [
  { username = "lucas.zanoni"; }
  { username = "new.member"; }  # Add here
];
```

2. **Create user directory and files:**
```bash
mkdir -p users/new.member
```

3. **Create `users/new.member/default.nix`:**
```nix
{ ... }:
{
  imports = [
    ./pkgs.nix
  ];
}
```

4. **Create `users/new.member/pkgs.nix`:**
```nix
{
  pkgs,
  pkgsLatest,
  ...
}:
{
  home.packages = with pkgs; [
    # Add user-specific packages here
    # Example:
    # vscode
    # docker
  ];
}
```

5. **Test the build:**
```bash
make build USER=new.member
```

## 📦 What's Included

### Common Tools (all users)
- **Version Control:** git
- **Development:** devenv, direnv, uv
- **API Testing:** insomnia, postman
- **Database Tools:** lens (K8s), redisinsight
- **Utilities:** curl, ripgrep-all, xclip, zip/unzip
- **Nix Tools:** alejandra, nixd, nixfmt-rfc-style

### Python Environment (pipx module)
- pipx for isolated Python app installations
- Configured with `~/.local/bin` in PATH

### JVM Environment (sdkman module)
- SDKMAN! for Java, Gradle, Maven management
- Auto-installs on first activation

## 🏗️ Project Structure

```
aplicacoes-env/
├── flake.nix              # Main entry point - defines users and inputs
├── home.nix               # Base configuration for ALL users
├── modules/               # Shared modules
│   ├── pipx.nix          # Python package manager setup
│   └── sdkman.nix        # JVM tooling manager setup
├── users/                 # User-specific configurations
│   └── {username}/
│       ├── default.nix   # User entry point
│       └── pkgs.nix      # User-specific packages
├── tests/                 # Test suite
│   ├── run-tests.sh      # Main test runner
│   ├── validate-modules.sh
│   └── scripts/          # BATS test files
├── .github/workflows/     # CI/CD configuration
├── Makefile              # Helper commands
├── CLAUDE.md             # AI assistant guidance
└── README.md             # This file
```

## 🛠️ Common Commands

We provide a Makefile for convenience:

```bash
# Build a user's configuration (doesn't activate)
make build USER=lucas.zanoni

# Build and activate configuration
make switch USER=lucas.zanoni

# Run tests
make test

# Format code
make format

# Update dependencies
make update

# Update only latest packages
make update-latest

# Show all commands
make help
```

## 🧪 Testing

Run the test suite before committing:

```bash
make test
```

This will:
- Validate flake syntax
- Check all modules for syntax errors
- Run any BATS tests in `tests/scripts/`

## 📚 Package Selection Strategy

We provide three package channels:

- **`pkgs`** - Stable packages from nixos-25.05 (use this by default)
- **`pkgsUnstable`** - Newer packages from nixos-unstable
- **`pkgsLatest`** - Bleeding edge (updated manually with `make update-latest`)

Example usage in a user's `pkgs.nix`:
```nix
{
  pkgs,
  pkgsLatest,
  ...
}:
{
  home.packages = with pkgs; [
    # Stable versions
    git
    curl

    # Latest versions
    pkgsLatest.vscode
  ];
}
```

## 🔧 Development Workflow

### Making Changes

1. **Edit files** (add packages, modify modules, etc.)
2. **Test locally:**
   ```bash
   make test
   make build USER=your.name
   ```
3. **Format code:**
   ```bash
   make format
   ```
4. **Commit and push** - CI will validate automatically

### Creating New Modules

See existing modules in `modules/` for patterns:

- **Simple packages:** Just add to `home.packages` (see `pipx.nix`)
- **Complex setup:** Use `home.activation` for installation scripts (see `sdkman.nix`)
- **Config files:** Use `home.file.{name}.source` to symlink dotfiles

## 💡 Tips

### Explore Nix Options

Use the Nix REPL to explore available options:

```bash
make repl
```

Then in the REPL:
```nix
:lf .#homeConfigurations.lucas.zanoni@x86_64-linux
builtins.attrNames config.options.programs
config.options.programs.git.enable.description
```

### Rollback Changes

If something breaks:
```bash
# Home Manager keeps generations
home-manager generations

# Rollback to a specific generation
/nix/store/...-home-manager-generation/activate
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `make test && make format`
5. Submit a pull request

CI will automatically:
- Check code formatting
- Validate flake syntax
- Build test configurations
- Run the test suite

## 📖 Resources

- [Nix Manual](https://nixos.org/manual)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS & Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book)

---

Built with ❤️ for the Aplicações team
