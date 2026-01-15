# <img src="https://www.hashicorp.com/img/vault/vault-logo-color.svg" width="32"> Sapphive Vault-over-Tor

![Docker Pulls](https://img.shields.io/docker/pulls/sapphive/vault-over-tor) ![License](https://img.shields.io/badge/license-MIT-green) ![Security](https://img.shields.io/badge/security-hardened-orange)

## 🚀 The Solution
**Vault-over-Tor** is a specialized orchestration of HashiCorp Vault hardened for the darknet. It is designed for organizations and individuals who need to manage highly sensitive credentials across distributed networks without the cost or complexity of traditional VPNs, leased lines, or public-facing load balancers.

By utilizing the **Sapphive Tor Onion Sidecar**, this suite exposes the Vault API exclusively through a Version 3 Onion Service.

---

## 🛡️ Why Vault-over-Tor?

| Feature | Standard Vault | Vault-over-Tor |
| :--- | :--- | :--- |
| **Network Access** | Public IP / VPN required | **Hidden Service (.onion) only** |
| **Firewall Setup** | Port 8200 must be open | **Zero open ports (Inbound)** |
| **Metadata** | ISP sees traffic destination | **Traffic destination is masked** |
| **NAT Traversal** | Requires Port Forwarding | **Works behind CGNAT & Firewalls** |
| **Identity** | IP Address / DNS | **Secret 56-character cryptographic ID** |

---

## 🎯 Professional Use Cases

### 1. **Multi-Cloud Secret Synchronization**
Manage secrets for clusters running on AWS, Azure, and a private home lab simultaneously. All workers connect to the central Vault via the `.onion` address, ensuring a unified security policy regardless of the hosting provider.

### 2. **Secure IoT Command & Control**
Deploy field devices (Raspberry Pis, industrial sensors) that need to rotate their own API keys. Since these devices often live behind cellular (LTE) networks with no public IP, Vault-over-Tor provides the only reliable way to fetch secrets remotely.

### 3. **The "Last Stand" Backup**
Even if your primary corporate VPN is compromised or taken down, your Vault remains accessible via the Tor network, providing a "break-glass" emergency access to critical infrastructure passwords.

---

## 🧪 Proof of Concept: Automated Remote Access

You don't need a browser to use this. You can interact with your secret store programmatically from anywhere in the world using this Python snippet.

### `test-connection.py` (Remote Secret Fetcher)
```python
import requests

# CONFIGURATION
ONION_URL = "http://your_secret_address.onion/v1/secret/data/test"
ROOT_TOKEN = "your_vault_root_token"

# PROXY CONFIG (Must have Tor running locally, e.g., 'sapphive/tor:latest')
proxies = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050'
}

def get_secret():
    headers = {"X-Vault-Token": ROOT_TOKEN}
    try:
        response = requests.get(ONION_URL, headers=headers, proxies=proxies)
        data = response.json()
        print(f"✅ Success! Secret retrieved: {data['data']['data']}")
    except Exception as e:
        print(f"❌ Connection failed: {e}")

if __name__ == "__main__":
    get_secret()
```

---

## ⚙️ How it Works (Under the Hood)

1.  **Vault Instance:** Runs in a locked-down container with `IPC_LOCK` enabled to prevent memory from being swapped to disk (security best practice).
2.  **Encrypted Volume:** All data is stored in the `./data` directory using AES-GCM-256 encryption.
3.  **Sidecar Tunnel:** The `tor-gate` container creates a virtual circuit to the Tor network and mapping a local `.onion` address to `vault:8200`.
4.  **Health-Sync:** The tunnel does not open until Vault passes its internal readiness probe.

---

## 🔒 Security Best Practices Checklist
When deploying Vault-over-Tor in a production environment, ensure you follow these steps:
1.  **Seal the Vault:** Access via `.onion` is encrypted, but always use `vault operator seal` if you suspect the physical host is compromised.
2.  **External Keys:** Keep your `./keys` directory (the Onion ID) on a separate encrypted volume if possible. 
3.  **Firewall:** Ensure your host machine allows **no inbound traffic** to port 8200 from the public internet. Only the internal Docker network should bridge these.

---

## 🤝 Support & Maintenance
Developed by the **SAPPHIVE Infrastructure Team**.
*   **Website:** [sapphive.com](https://sapphive.com)
*   **Documentation:** [GitHub: sapphive/vault-over-tor](https://github.com/sapphive/vault-over-tor)
*   **Support:** [support@sapphive.com](mailto:support@sapphive.com)

---

## ⚖️ Legal
HashiCorp Vault is a trademark of HashiCorp, Inc. Tor is a trademark of The Tor Project, Inc. This project is a community-driven implementation and is not an official product of either organization.
