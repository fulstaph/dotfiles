#!/usr/bin/env bash
# scripts/test-linux-container.sh — run test-zshrc.sh inside a container
# Requires podman or docker.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME=""
for r in podman docker; do
  command -v "$r" &>/dev/null && RUNTIME="$r" && break
done
[[ -z "$RUNTIME" ]] && echo "error: need podman or docker" && exit 1

echo "==> Running zshrc test in Ubuntu 24.04 container (via $RUNTIME)..."
exec "$RUNTIME" run --rm \
  -v "$DOTFILES:/dotfiles:ro" \
  ubuntu:24.04 \
  bash /dotfiles/scripts/test-zshrc.sh
