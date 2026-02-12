#!/usr/bin/env bash
# Test the Nix flake by building it inside a Docker container.
# Usage: ./tests/test-nix.sh [eval|full]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="${1:-eval}"

case "$MODE" in
  eval)
    echo "=== Quick Evaluation Test ==="
    echo "Building test container..."
    docker build -t aplicacoes-env-test:eval -f "$SCRIPT_DIR/Dockerfile" "$PROJECT_DIR"
    echo ""
    echo "Running Nix validation..."
    docker run --rm aplicacoes-env-test:eval
    echo ""
    echo "Evaluation test passed."
    ;;

  full)
    echo "=== Full Deployment Test ==="
    echo "Building full test container..."
    docker build -t aplicacoes-env-test:full -f "$SCRIPT_DIR/Dockerfile.full" "$PROJECT_DIR"
    echo ""
    echo "Full deployment test passed."
    ;;

  *)
    echo "Usage: $0 [eval|full]"
    echo "  eval - Quick flake evaluation (default)"
    echo "  full - Full deployment with home-manager"
    exit 1
    ;;
esac
