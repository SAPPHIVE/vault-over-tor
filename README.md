# <img src="https://icon.icepanel.io/Technology/svg/HashiCorp-Vault.svg" height="32"> Sapphive Vault-over-Tor

![Project Status](https://img.shields.io/badge/status-initial--scaffolding-blue)

**Vault-over-Tor** is a privacy-first, zero-trust secrets management solution. It pairs [HashiCorp Vault](https://www.vaultproject.io/) with the [Sapphive Tor Onion Sidecar](https://hub.docker.com/r/sapphive/tor) to provide a secure, globally accessible vault that bypasses firewalls and NAT without exposing any ports to the public internet.

## 🌟 Why this exists?
Standard Vault deployments require complex VPNs or IP whitelisting for remote access. This project allows you to host your own secrets on a private server (even behind a home router/CGNAT) and access them from anywhere via a 56-character `.onion` address protected by Tor's end-to-end encryption.

## 🚀 Features
- 🔒 **Zero Public Ports:** No ingress required on your firewall.
- 🧅 **Onion Routing:** Metadata is hidden from ISPs and network snoopers.
- 🌐 **Simplified Access:** Access Vault via port 80 on the darknet (maps to 8200 internally).
- 🛡️ **End-to-End Encryption:** Traffic is encrypted by both TLS (optional) and the Tor network.
- 📦 **Docker Primary:** Spin up a production-ready secret store in seconds.

## 🛠️ Quick Start

### 1. Requirements
- Docker and Docker Compose installed.

### 2. Launch
```bash
docker-compose up -d
```

### 3. Docker Compose Example
If you are integrating this into your own stack, use this `docker-compose.yml` configuration:

```yaml
services:
  vault-service:
    image: sapphive/vault-over-tor:latest
    container_name: vault-service
    ports:
      # Use VAULT_PORT env to change the host port (Default: 80)
      - "${VAULT_PORT:-80}:8200"
    volumes:
      - ./data:/vault/file
      - ./keys:/var/lib/tor/hidden_service
    cap_add:
      - IPC_LOCK
    restart: always
```

### 4. Initialize & Unseal
Vault starts in a "Sealed" state for security. Use our helper script to initialize it:
```bash
# Make script executable
chmod +x init-vault.sh

# Run initialization
./init-vault.sh
```
*This will give you your **Root Token** and **Unseal Key**. Save them offline!*

### 4. Get your Onion Address
Check your logs to find your unique `.onion` URL:
```bash
docker logs vault-service
```

**Expected Output:**
```text
***************************************************
  🚀 SAPPHIVE VAULT-OVER-TOR IS ACTIVE
  📍 PUBLIC ONION: http://v2c3...f4g5.onion
  🔒 SECURE ONION: https://v2c3...f4g5.onion
  🔐 ACCESS YOUR SECRETS SECURELY AT THESE URLS
***************************************************
```

---

## 🏗️ Project Structure
- `docker-compose.yml`: Orchestrates Vault and the Tor Sidecar.
- `config/`: Contains Vault security policies and configuration.
- `data/`: (Volume) Persistent storage for Vault encrypted data.
- `keys/`: (Volume) Persistent storage for your `.onion` identity keys.

## ⚖️ Legal Disclaimer
Vault is a trademark of HashiCorp. Tor is a trademark of The Tor Project. This project is maintained by [SAPPHIVE](https://sapphive.com) and is not affiliated with HashiCorp or The Tor Project.
