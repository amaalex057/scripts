### INI File Parser
Coming from : https://github.com/DevelopersToolbox/ini-file-parser/blob/master/src/ini-file-parser.sh

### Software installer

`install_software.sh` is a self-contained installer for the supported software:

```sh
bash install_software.sh zellij
bash install_software.sh tugtainer
bash install_software.sh watchtower
bash install_software.sh caddy
```

The script can also be fetched and run directly, for example:

```sh
curl -fsSL <installer-url> | bash -s -- zellij
```

The Tugtainer and Watchtower installers write `compose.yml` in the current
directory. Watchtower's Telegram notification token and chat ID must be set as
`WATCHTOWER_NOTIFICATION_TOKEN` and `WATCHTOWER_NOTIFICATION_CHAT_ID` when
starting the Compose service.
