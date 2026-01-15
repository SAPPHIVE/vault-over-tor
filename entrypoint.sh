#!/bin/bash

# Ensure Tor data directory has correct permissions
# We need to ensure the user running Tor (even if triggered by entrypoint as root)
# can access these files.
chown -R tor:tor /var/lib/tor
chmod 700 /var/lib/tor
chmod 700 /var/lib/tor/hidden_service

# Start Tor in the background as the 'tor' user to generate the onion address
echo "🧅 Starting Tor to establish Hidden Service circuit..."
su -s /bin/bash tor -c "tor -f /etc/tor/torrc --RunAsDaemon 1"

# Wait for the onion address to be generated
MAX_RETRIES=30
COUNT=0
echo "⏳ Waiting for .onion address generation..."
while [ ! -f /var/lib/tor/hidden_service/hostname ]; do
    sleep 2
    COUNT=$((COUNT+1))
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "❌ Error: Tor failed to generate a hostname. check logs."
        exit 1
    fi
done

ONION_ADDR=$(cat /var/lib/tor/hidden_service/hostname)

echo "***************************************************"
echo "  🚀 SAPPHIVE VAULT-OVER-TOR IS ACTIVE"
echo "  📍 YOUR ONION ADDRESS: $ONION_ADDR"
echo "  🔐 ACCESS YOUR SECRETS SECURELY AT THIS URL"
echo "***************************************************"

# Shutdown the background Tor so Supervisor can manage it properly
pkill tor
sleep 1

# Start Supervisor to manage both Vault and Tor in the foreground
exec /usr/bin/supervisord -c /etc/supervisord.conf
