#!/bin/bash
set -e

CONFIG_FILE="./roundcube-config/config.inc.php"

if [ -f "$CONFIG_FILE" ]; then
    if ! grep -q "des_key" "$CONFIG_FILE" || grep -qE "des_key'\s*\]\s*=\s*['\"]{2}" "$CONFIG_FILE"; then
        echo "--> Local des_key is missing or empty. Generating a secure one via OpenSSL..."
        RANDOM_KEY=$(openssl rand -base64 18)
        
        sed -i '' '/des_key/d' "$CONFIG_FILE" 2>/dev/null || sed -i '/des_key/d' "$CONFIG_FILE"

        echo "\$config['des_key'] = '${RANDOM_KEY}';" >> "$CONFIG_FILE"
        echo "--> Successfully injected key into $CONFIG_FILE"
    else
        echo "--> Valid des_key found in local config, skipping generation."
    fi
else
    echo "Warning: $CONFIG_FILE not found. Skipping key injection."
fi

echo "--> Verifying mail directory paths..."
mkdir -p ./maildata ./mbsync

echo "--> Launching the mail stack containers..."
docker compose up -d


echo "--> Email stack is up!!"