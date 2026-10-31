#!/bin/bash

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
      # Requires you to explicitly enable containers for updates (highly recommended)
      # Only update containers that have the label "com.centurylinklabs.watchtower.enable=true"
      - WATCHTOWER_LABEL_ENABLE=true
      # Notifications 
      - WATCHTOWER_NOTIFICATIONS=telegram
      - WATCHTOWER_NOTIFICATION_TOKEN=8654646865:AAE5PI5rptTEH5m1HTJ6Lm1Msb3hvGSGJaw
      - WATCHTOWER_NOTIFICATION_CHAT_ID=6685816249

EOF
