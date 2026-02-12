#!/usr/bin/env bash

set -euo pipefail

[ "${SKIP_HOOKS:-0}" = "1" ] && exit 0

REPO_ROOT=$(git rev-parse --show-toplevel)

[[ "$(basename "$REPO_ROOT")" != "aplicacoes-env" ]] && exit 0

cd "$REPO_ROOT"

run_check() {
  local checkName="$1"
  shift
  echo "==> $checkName"
  "$@"
  echo ""
}

run_check "statix" \
  nix run nixpkgs#statix -- check . --ignore 'result*'

run_check "deadnix" \
  nix run nixpkgs#deadnix -- .

run_check "nixfmt" \
  bash -c "find . -name '*.nix' -not -path './result*' -exec nix run nixpkgs#nixfmt-rfc-style -- --check {} +"

run_check "build" \
  nix build '.#homeConfigurations.default.activationPackage' --impure --no-link

echo "All pre-push checks passed."
