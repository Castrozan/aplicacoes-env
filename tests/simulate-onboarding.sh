#!/usr/bin/env bash
set -euo pipefail

echo "=== Simulating new team member onboarding ==="
echo "User: $(whoami)"
echo "Home: $HOME"
echo ""

# README Step 1: Install Nix (already done in Dockerfile)
echo "=== Step 1: Nix is installed ==="
nix --version
echo ""

# README Step 2: Clone and apply
echo "=== Step 2: Clone and apply ==="
cp -r /src ~/aplicacoes-env
cd ~/aplicacoes-env
git config core.hooksPath .githooks
echo "Hooks path set to .githooks"
echo ""

# README: make switch
echo "=== Step 3: make switch ==="
set +e
make switch
SWITCH_RC=$?
set -e
if [ "$SWITCH_RC" -ne 0 ]; then
  echo "FAIL: make switch exited with code $SWITCH_RC"
  exit 1
fi
echo "make switch: OK"
echo ""

# Add nix-profile to PATH so we can verify installed packages
export PATH="$HOME/.nix-profile/bin:$PATH"

echo "=== Verifying: packages from README ==="
FAIL=0

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "  ok: $1"
  else
    echo "  FAIL: $1 not found"
    FAIL=1
  fi
}

echo "Dev Tools:"
check_cmd devenv

echo "Nix Tooling:"
check_cmd alejandra
check_cmd nixd
check_cmd nixfmt
echo ""

echo "=== Verifying: idempotency (run make switch again) ==="
cd ~/aplicacoes-env
set +e
make switch
SWITCH2_RC=$?
set -e
if [ "$SWITCH2_RC" -ne 0 ]; then
  echo "FAIL: second make switch exited with code $SWITCH2_RC"
  exit 1
fi
echo "  ok: second switch succeeded"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "=== ONBOARDING SIMULATION PASSED ==="
else
  echo "=== ONBOARDING SIMULATION FAILED ==="
  exit 1
fi
