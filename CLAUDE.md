# CLAUDE.md

Standalone Home Manager flake (not NixOS). Provides base dev tooling for team Aplicacoes. Human docs are in README.md.

## Where things are

- `flake.nix` — entry point. Defines inputs (nixpkgs, home-manager, agenix), three package channels, `$USER` detection via `builtins.getEnv`, and `homeManagerModules` for external consumption.
- `home/core.nix` — username, homeDirectory, stateVersion. Receives `username` and `version` via specialArgs.
- `home/pkgs.nix` — all directly installed packages. Receives `pkgs`, `pkgsLatest`, `inputs`.
- `home/modules.nix` — imports all modules from `home/modules/`.
- `home/modules/agenix.nix` — agenix secret definitions. Uses `builtins.pathExists` so missing .age files don't break evaluation.
- `home/modules/npmrc.nix` — deploys base `.npmrc` via `home.activation` (copy-if-not-exists pattern). Also defines `inject-npm-auth` systemd user service that runs after `agenix.service` to append `_authToken`.
- `home/modules/git.nix` — deploys `.gitconfig` via `home.activation` (copy-if-not-exists). Delta pager, username-based email.
- `home/modules/shell.nix` — EKS aliases, session variables, PATH additions.
- `home/modules/ssh.nix` — deploys `~/.ssh/config` via `home.activation` (copy-if-not-exists). MatchBlocks for gitlab.services.betha.cloud and github.com.
- `secrets/secrets.nix` — agenix public key registry. Lists authorized SSH pubkeys per secret.
- `secrets/*.age` — age-encrypted files. Decrypted at login by `agenix.service` systemd user service to `$XDG_RUNTIME_DIR/agenix/`.
- `tests/test-key` — committed CI keypair for Docker tests. No security value.
- `tests/encrypt-test-secrets.sh` — regenerates test `.age` files using the CI test key.

## Key patterns

- `home.activation` for one-time file deployments (copy if not exists), not `home.file` symlinks — users can modify files locally after setup.
- All modules receive `username`, `inputs`, `pkgs`, `pkgsLatest`, `version` via specialArgs.
- Agenix HM module decrypts via systemd user service at login, NOT during `home-manager switch`. In Docker tests, manually extract and run ExecStart from the generated systemd units.
- `builtins.pathExists` for graceful degradation when .age files don't exist yet.
- `--impure` flag required for `$USER` detection via `builtins.getEnv`.

## How to test

```bash
make test-eval    # Quick: flake evaluation in Docker
make test-full    # Full: home-manager activation + agenix decryption
make test         # Both
make lint         # statix + deadnix + nixfmt check
```

## How to build and apply

```bash
make switch
# or: nix run home-manager -- switch --flake .#"$USER@x86_64-linux" --impure
```

## Formatting

All nix files use nixfmt (RFC style). Run `make fmt`.
