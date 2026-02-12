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

echo "Core:"
check_cmd git
check_cmd curl
check_cmd rga
check_cmd xclip
check_cmd zip
check_cmd unzip

echo "Cloud/K8s:"
check_cmd aws
check_cmd kubectl
check_cmd k9s
check_cmd docker-compose

echo "Dev Tools:"
check_cmd devenv
check_cmd direnv
check_cmd uv

echo "Nix Tooling:"
check_cmd alejandra
check_cmd nixd
check_cmd nixfmt
check_cmd agenix
echo ""

echo "=== Verifying: git config deployed ==="
if [ -f "$HOME/.gitconfig" ]; then
  echo "  ok: .gitconfig exists"
  if grep -q "joao.silva@betha.com.br" "$HOME/.gitconfig"; then
    echo "  ok: email is joao.silva@betha.com.br"
  else
    echo "  FAIL: email not set correctly"
    echo "  content:"
    cat "$HOME/.gitconfig"
    FAIL=1
  fi
  if grep -q "delta" "$HOME/.gitconfig"; then
    echo "  ok: delta pager configured"
  else
    echo "  FAIL: delta not in gitconfig"
    FAIL=1
  fi
else
  echo "  FAIL: .gitconfig not deployed"
  FAIL=1
fi
echo ""

echo "=== Verifying: ssh config deployed ==="
if [ -f "$HOME/.ssh/config" ]; then
  echo "  ok: ~/.ssh/config exists"
  PERMS=$(stat -c '%a' "$HOME/.ssh/config")
  if [ "$PERMS" = "600" ]; then
    echo "  ok: permissions 600"
  else
    echo "  FAIL: permissions are $PERMS, expected 600"
    FAIL=1
  fi
  if grep -q "gitlab.services.betha.cloud" "$HOME/.ssh/config"; then
    echo "  ok: gitlab matchblock present"
  else
    echo "  FAIL: gitlab matchblock missing"
    FAIL=1
  fi
  if grep -q "github.com" "$HOME/.ssh/config"; then
    echo "  ok: github matchblock present"
  else
    echo "  FAIL: github matchblock missing"
    FAIL=1
  fi
else
  echo "  FAIL: ~/.ssh/config not deployed"
  FAIL=1
fi
echo ""

echo "=== Verifying: .npmrc deployed ==="
if [ -f "$HOME/.npmrc" ]; then
  echo "  ok: .npmrc exists"
  if grep -q "nexus3.betha.com.br" "$HOME/.npmrc"; then
    echo "  ok: nexus registry configured"
  else
    echo "  FAIL: nexus registry not in .npmrc"
    FAIL=1
  fi
else
  echo "  FAIL: .npmrc not deployed"
  FAIL=1
fi
echo ""

echo "=== Verifying: shell aliases available ==="
if [ -f "$HOME/.profile" ] || [ -f "$HOME/.bashrc" ]; then
  echo "  ok: shell profile exists"
else
  echo "  info: no .profile or .bashrc (shell aliases may be in nix-managed files)"
fi
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

echo "=== Verifying: files survive re-switch ==="
if [ -f "$HOME/.gitconfig" ]; then
  echo "  ok: .gitconfig still exists after re-switch"
else
  echo "  FAIL: .gitconfig was deleted by re-switch"
  FAIL=1
fi
if [ -f "$HOME/.ssh/config" ]; then
  echo "  ok: ssh config still exists after re-switch"
else
  echo "  FAIL: ssh config was deleted by re-switch"
  FAIL=1
fi
if [ -f "$HOME/.npmrc" ]; then
  echo "  ok: .npmrc still exists after re-switch"
else
  echo "  FAIL: .npmrc was deleted by re-switch"
  FAIL=1
fi
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "=== ONBOARDING SIMULATION PASSED ==="
else
  echo "=== ONBOARDING SIMULATION FAILED ==="
  exit 1
fi
