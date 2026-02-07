#!/usr/bin/env bash
# Run all tests
# Usage: ./tests/run-tests.sh [--ci]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --ci) CI_MODE=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== Running Tests ==="
echo ""

# Flake validation
echo "--- Flake Validation ---"
if command -v nix &> /dev/null; then
    nix flake metadata
    echo "✓ Flake metadata valid"
else
    echo "WARN: nix not installed, skipping flake validation"
fi
echo ""

# Module validation
echo "--- Module Validation ---"
"$SCRIPT_DIR/validate-modules.sh"
echo ""

# Script tests (if bats is available)
if command -v bats &> /dev/null; then
    echo "--- Script Tests (bats) ---"
    if [ -n "$(ls -A "$SCRIPT_DIR/scripts" 2>/dev/null)" ]; then
        bats "$SCRIPT_DIR/scripts/"
    else
        echo "No test scripts found in tests/scripts/"
    fi
else
    if [[ "$CI_MODE" == "true" ]]; then
        echo "SKIP: bats not installed"
    else
        echo "WARN: bats not installed, skipping script tests"
        echo "      Install with: nix shell nixpkgs#bats"
    fi
fi

echo ""
echo "=== All Tests Complete ==="
