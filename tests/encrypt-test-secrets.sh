#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$REPO_DIR/secrets"
TEST_KEY="$SCRIPT_DIR/test-key"
TEST_PUBKEY="$SCRIPT_DIR/test-key.pub"

if [ ! -f "$TEST_KEY" ]; then
  echo "Generating CI test key pair..."
  ssh-keygen -t ed25519 -f "$TEST_KEY" -N "" -C "ci-test-key@aplicacoes-env" -q
  echo "  -> test-key + test-key.pub generated"
fi

CI_PUBKEY=$(cat "$TEST_PUBKEY")

cat > "$SECRETS_DIR/secrets.nix" << NIXEOF
let
  lucas-zanoni = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdOdWOmB7IhmU70+VwgUJ40MHCOwhhrDBn6rq/Fskq/";
  ci-test = "$CI_PUBKEY";
  all-keys = [
    lucas-zanoni
    ci-test
  ];
in
{
  "npm-auth-token.age".publicKeys = all-keys;
  "gitlab-deploy-token.age".publicKeys = all-keys;
  "aws-credentials.age".publicKeys = all-keys;
}
NIXEOF
echo "  -> secrets.nix updated with CI test public key"

RECIPIENT_ARGS=(-R "$TEST_PUBKEY")

echo "Encrypting test secrets with CI test key..."

echo -n "test-npm-auth-token-placeholder" | age "${RECIPIENT_ARGS[@]}" -o "$SECRETS_DIR/npm-auth-token.age"
echo "  -> npm-auth-token.age"

echo -n "test-gitlab-deploy-token-placeholder" | age "${RECIPIENT_ARGS[@]}" -o "$SECRETS_DIR/gitlab-deploy-token.age"
echo "  -> gitlab-deploy-token.age"

printf '[default]\naws_access_key_id = TEST_KEY_ID\naws_secret_access_key = TEST_SECRET_KEY\n' | age "${RECIPIENT_ARGS[@]}" -o "$SECRETS_DIR/aws-credentials.age"
echo "  -> aws-credentials.age"

echo "Done. Test secrets encrypted to $SECRETS_DIR/"
