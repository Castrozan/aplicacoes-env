#!/usr/bin/env bash
set -euo pipefail

TEST_USER="${1:-joao.silva}"
REPO_SOURCE="${2:-}"

echo "=== aplicacoes-env VM test setup ==="
echo "Target user: $TEST_USER"
echo "Running as: $(whoami)"
echo ""

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root (or with sudo)"
  exit 1
fi

echo "=== Step 1: Install system dependencies ==="
apt-get update -qq
apt-get install -y -qq --no-install-recommends curl xz-utils ca-certificates git sudo make
echo ""

echo "=== Step 2: Create test user ==="
if id "$TEST_USER" &>/dev/null; then
  echo "User $TEST_USER already exists, skipping creation"
else
  useradd -m -s /bin/bash "$TEST_USER"
  echo "$TEST_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  echo "Created user $TEST_USER with sudo access"
fi
echo ""

echo "=== Step 3: Install Nix ==="
if sudo -u "$TEST_USER" bash -c 'command -v nix' &>/dev/null; then
  echo "Nix already installed, skipping"
else
  mkdir -p /nix
  chown "$TEST_USER" /nix
  sudo -u "$TEST_USER" bash -c 'curl -L https://nixos.org/nix/install | bash -s -- --no-daemon'
  sudo -u "$TEST_USER" bash -c 'mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf'
  echo "Nix installed"
fi
echo ""

echo "=== Step 4: Set up aplicacoes-env repo ==="
TARGET_DIR="/home/$TEST_USER/aplicacoes-env"

if [ -d "$TARGET_DIR" ]; then
  echo "Repo already exists at $TARGET_DIR, skipping"
elif [ -n "$REPO_SOURCE" ] && [ -d "$REPO_SOURCE" ]; then
  sudo -u "$TEST_USER" cp -r "$REPO_SOURCE" "$TARGET_DIR"
  echo "Copied repo from $REPO_SOURCE"
else
  echo "No repo source provided. Clone it manually:"
  echo "  sudo -u $TEST_USER git clone <url> $TARGET_DIR"
  echo ""
  echo "Or re-run with a source path:"
  echo "  sudo bash tests/setup-vm-test.sh $TEST_USER /path/to/aplicacoes-env"
  exit 0
fi

sudo -u "$TEST_USER" bash -c "cd $TARGET_DIR && rm -f .gitconfig .npmrc && rm -rf ~/.ssh"
sudo -u "$TEST_USER" bash -c "cd $TARGET_DIR && git init 2>/dev/null || true"
sudo -u "$TEST_USER" bash -c "cd $TARGET_DIR && git config user.email test@test.com && git config user.name test"
sudo -u "$TEST_USER" bash -c "cd $TARGET_DIR && git add -A && git commit -m 'initial' --allow-empty 2>/dev/null || true"
sudo -u "$TEST_USER" bash -c "cd $TARGET_DIR && git config core.hooksPath .githooks"
echo ""

echo "=== Step 5: Apply flake ==="
sudo -u "$TEST_USER" bash -c "export PATH=\$HOME/.nix-profile/bin:\$PATH && cd $TARGET_DIR && make switch"
echo ""

echo "=== Setup complete ==="
echo ""
echo "You can now log in as $TEST_USER and test manually:"
echo "  su - $TEST_USER"
echo ""
echo "Or run the full onboarding verification:"
echo "  sudo -u $TEST_USER bash $TARGET_DIR/tests/simulate-onboarding.sh"
