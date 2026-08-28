#!/bin/bash

set -euo pipefail

# Download the tugtainer docker compose file and save it to the current directory.
curl -L -o compose.yml https://github.com/Quenary/tugtainer/raw/main/docker-compose.app.yml

# Generate a strong shared secret and inject it into the compose file.
SECRET="$(openssl rand -base64 32)"

if ! grep -q 'AGENT_SECRET' compose.yml; then
  echo "AGENT_SECRET not found in compose.yml. Please verify the upstream file format."
  exit 1
fi

# Preserve the original indentation so the YAML stays valid.
sed -i.bak -E "s|^([[:space:]]*)#?[[:space:]]*AGENT_SECRET:.*|\\1AGENT_SECRET: \"${SECRET}\"|" compose.yml

# Change TZ: Europe/Moscow to TZ: Asia/Kolkata in compose.yml
sed -i.bak -E "s|^([[:space:]]*)#?[[:space:]]*TZ:.*|\\1TZ: Asia/Kolkata|" compose.yml

echo "Generated a new AGENT_SECRET and updated compose.yml."
echo "Review the file, then start the service with: docker compose up -d"

