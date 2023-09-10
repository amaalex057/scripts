#!/bin/bash

echo "Upgrading Debian"

read -p "Upgrade From [bullseye]: " source
source=${source:-bullseye}

read -p "Upgrade To [bookworm]: " dest
dest=${dest:-bookworm}

apt update && apt upgrade -y && apt autoremove -y
sed -ibak -e "s/${source}/${dest}/g" /etc/apt/sources.list 
apt update && apt upgrade -y && apt autoremove -y
apt full-upgrade -y
