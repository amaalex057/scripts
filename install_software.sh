#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install_software.sh <software>

Software:
  zellij
  tugtainer
  watchtower
  caddy
EOF
}

get_latest_tag() {
  local base="https://github.com/$1"
  local effective_url

  effective_url=$(curl -fsSL -o /dev/null -w '%{url_effective}' "${base}/releases/latest")
  printf '%s\n' "${effective_url##*/}"
}

install_zellij() {
  # Clean up the deb.griffo.io repo if still present.
  sudo rm -f /etc/apt/sources.list.d/deb.griffo.io.list /etc/apt/keyrings/deb.griffo.io.gpg

  local target
  case "$(uname -m)" in
    x86_64) target="x86_64-unknown-linux-musl" ;;
    aarch64) target="aarch64-unknown-linux-musl" ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      return 1
      ;;
  esac

  local org="zellij-org"
  local project="zellij"
  local latest_tag
  latest_tag=$(get_latest_tag "${org}/${project}")
  echo "Found version: ${latest_tag}"

  # The EXIT trap runs after this function returns, so keep its path in global scope.
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT

  local download_url="https://github.com/${org}/${project}/releases/download/${latest_tag}/zellij-${target}.tar.gz"
  curl -fsSL "$download_url" -o "${tmp_dir}/zellij.tar.gz"
  tar -xzf "${tmp_dir}/zellij.tar.gz" -C "$tmp_dir"
  sudo install -m 0755 "${tmp_dir}/zellij" /usr/local/bin/zellij

  echo "Installed: $(zellij --version)"
}

install_tugtainer() {
  curl -fsSL -o compose.yml https://github.com/Quenary/tugtainer/raw/main/docker-compose.app.yml

  local secret
  secret="$(openssl rand -base64 32)"

  if ! grep -q 'AGENT_SECRET' compose.yml; then
    echo "AGENT_SECRET not found in compose.yml. Please verify the upstream file format." >&2
    return 1
  fi

  sed -i.bak -E "s|^([[:space:]]*)#?[[:space:]]*AGENT_SECRET:.*|\\1AGENT_SECRET: \"${secret}\"|" compose.yml
  sed -i.bak -E "s|^([[:space:]]*)#?[[:space:]]*TZ:.*|\\1TZ: Asia/Kolkata|" compose.yml

  echo "Generated a new AGENT_SECRET and updated compose.yml."
  echo "Review the file, then start the service with: docker compose up -d"
}

install_watchtower() {
  cat > compose.yml <<'EOF'
---

services:
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      # Runs Watchtower daily at 3:00 AM using a Cron expression
      - WATCHTOWER_SCHEDULE=0 0 3 * * *
      # Automatically removes the old docker image after updating to free up disk space
      - WATCHTOWER_CLEANUP=true
      # Only update containers labeled "com.centurylinklabs.watchtower.enable=true"
      - WATCHTOWER_LABEL_ENABLE=true
      # Configure these in the environment before running docker compose.
      - WATCHTOWER_NOTIFICATIONS=telegram
      - WATCHTOWER_NOTIFICATION_TOKEN=${WATCHTOWER_NOTIFICATION_TOKEN:?Set WATCHTOWER_NOTIFICATION_TOKEN}
      - WATCHTOWER_NOTIFICATION_CHAT_ID=${WATCHTOWER_NOTIFICATION_CHAT_ID:?Set WATCHTOWER_NOTIFICATION_CHAT_ID}
EOF

  echo "Created compose.yml for Watchtower."
  echo "Set WATCHTOWER_NOTIFICATION_TOKEN and WATCHTOWER_NOTIFICATION_CHAT_ID before running: docker compose up -d"
}

install_caddy() {
  echo "=== Updating package list and installing dependencies ==="
  sudo apt update
  sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

  echo "=== Adding Caddy GPG security key ==="
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' |
    sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

  echo "=== Adding official Caddy repository ==="
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' |
    sudo tee /etc/apt/sources.list.d/caddy-stable.list

  echo "=== Installing Caddy web server ==="
  sudo apt update
  sudo apt install -y caddy

  echo "=== Enabling and starting Caddy service ==="
  sudo systemctl daemon-reload
  sudo systemctl enable --now caddy

  echo "=== Caddy Installation Complete ==="
  caddy version
}

main() {
  if [[ $# -ne 1 ]]; then
    usage >&2
    return 2
  fi

  case "$1" in
    zellij) install_zellij ;;
    tugtainer) install_tugtainer ;;
    watchtower) install_watchtower ;;
    caddy) install_caddy ;;
    -h|--help) usage ;;
    *)
      echo "Unknown software: $1" >&2
      usage >&2
      return 2
      ;;
  esac
}

main "$@"
