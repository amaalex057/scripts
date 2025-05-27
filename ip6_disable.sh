#!/bin/bash

 # Define the desired lines
 declare -A SYSCTL_SETTINGS=(
   ["net.ipv6.conf.all.disable_ipv6"]="1"
   ["net.ipv6.conf.default.disable_ipv6"]="1"
 )

 SYSCTL_FILE="/etc/sysctl.conf"

 for key in "${!SYSCTL_SETTINGS[@]}"; do
     value="${SYSCTL_SETTINGS[$key]}"
     line="$key = $value"
     echo "Line => $line"

     if grep -qE "^\s*#?\s*$key\s*=" "$SYSCTL_FILE"; then
         # If the line exists (commented or not), uncomment and update it
         sed -i -E "s|^\s*#?\s*($key)\s*=.*|$line|" "$SYSCTL_FILE"
         echo "✅ Updated existing line: $line"
     else
         # If the line doesn't exist at all, append it
         echo "$line" >> "$SYSCTL_FILE"
         echo "✅ Appended new line: $line"
     fi
 done


 sysctl -p
