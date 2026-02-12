#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$REPO_DIR/secrets"
TEST_PUBKEY="$SCRIPT_DIR/test-key.pub"

if [ ! -f "$TEST_PUBKEY" ]; then
  echo "Error: test public key not found at $TEST_PUBKEY"
  exit 1
fi

RECIPIENT_ARGS=(-R "$TEST_PUBKEY")

echo "Encrypting test secrets with CI test key..."

echo -n "test-npm-auth-token-placeholder" | age "${RECIPIENT_ARGS[@]}" -o "$SECRETS_DIR/npm-auth-token.age"
echo "  -> npm-auth-token.age"

echo -n "test-gitlab-deploy-token-placeholder" | age "${RECIPIENT_ARGS[@]}" -o "$SECRETS_DIR/gitlab-deploy-token.age"
echo "  -> gitlab-deploy-token.age"

printf '[default]\naws_access_key_id = TEST_KEY_ID\naws_secret_access_key = TEST_SECRET_KEY\n' | age "${RECIPIENT_ARGS[@]}" -o "$SECRETS_DIR/aws-credentials.age"
echo "  -> aws-credentials.age"

echo "Done. Test secrets encrypted to $SECRETS_DIR/"
