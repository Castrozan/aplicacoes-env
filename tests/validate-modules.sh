#!/usr/bin/env bash
# Validate that all modules can be imported and have proper structure

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULES_DIR="$REPO_ROOT/modules"

echo "Validating modules in $MODULES_DIR"

# Check each .nix file in modules/
for module in "$MODULES_DIR"/*.nix; do
    if [ -f "$module" ]; then
        module_name=$(basename "$module")
        echo -n "  Checking $module_name... "

        # Basic syntax check using nix
        if nix-instantiate --parse "$module" > /dev/null 2>&1; then
            echo "✓"
        else
            echo "✗ (syntax error)"
            exit 1
        fi
    fi
done

echo "All modules validated successfully!"
