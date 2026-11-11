#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

# Clean up the deb.griffo.io repo if still present
sudo rm -f /etc/apt/sources.list.d/deb.griffo.io.list /etc/apt/keyrings/deb.griffo.io.gpg

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  TARGET="x86_64-unknown-linux-musl" ;;
  aarch64) TARGET="aarch64-unknown-linux-musl" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Build base path safely (no protocol + domain together)
ORG="zellij-org"
PROJ="zellij"

# Follow the /releases/latest redirect to get the exact tag name (e.g. v0.45.1)
LATEST_TAG=$(get_latest_tag "${ORG}/${PROJ}")
echo "Found version: ${LATEST_TAG}"

# Download and install the tarball
BASE="https://github.com/${ORG}/${PROJ}"

DL_URL="${BASE}/releases/download/${LATEST_TAG}/zellij-${TARGET}.tar.gz"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "$DL_URL" -o "${TMP_DIR}/zellij.tar.gz"
tar -xzf "${TMP_DIR}/zellij.tar.gz" -C "$TMP_DIR"
sudo install -m 0755 "${TMP_DIR}/zellij" /usr/local/bin/zellij

echo "Installed: $(zellij --version)"
