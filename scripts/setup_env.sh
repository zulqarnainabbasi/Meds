#!/usr/bin/env bash

set -euo pipefail

TOOLS=("bash" "grep" "awk" "sed")

echo "Checking required tools..."

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool"
    else
        echo "[MISSING] $tool"
        exit 1
    fi
done

echo "Environment setup complete."