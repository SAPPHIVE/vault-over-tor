#!/bin/bash

# Sapphive Vault-over-Tor Initialization Helper
echo "🛡️ Starting Vault Initialization..."

# Set VAULT_ADDR to use HTTP explicitly to avoid the TLS redirect error
export VAULT_ADDR="http://127.0.0.1:8200"

# Initialize Vault and capture the output
INIT_OUTPUT=$(docker exec -e VAULT_ADDR="http://127.0.0.1:8200" vault-service vault operator init -n 1 -t 1)

if [ $? -eq 0 ]; then
    echo "✅ Vault Initialized Successfully!"
    echo "---------------------------------------------------"
    echo "$INIT_OUTPUT"
    echo "---------------------------------------------------"
    echo "⚠️ SAVE THESE KEYS SECURELY! If you lose them, you lose your data."
    
    # Extract unseal key and root token
    UNSEAL_KEY=$(echo "$INIT_OUTPUT" | grep "Unseal Key 1:" | awk '{print $4}')
    
    echo "🔓 Unsealing Vault..."
    docker exec vault-service vault operator unseal "$UNSEAL_KEY"
    
    echo "🚀 Vault is now UNSEALED and ready at your .onion address!"
else
    echo "❌ Initialization failed. Is Vault already initialized?"
fi
