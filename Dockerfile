# Use the official Vault image as base
FROM hashicorp/vault:latest

# Install Tor and Supervisor
RUN apk add --no-cache tor supervisor bash curl

# Setup directory for Tor and Vault
RUN mkdir -p /var/lib/tor/hidden_service && \
    chown -R tor:tor /var/lib/tor && \
    chmod 700 /var/lib/tor/hidden_service

# Copy configurations and scripts
COPY config/vault-config.hcl /vault/config/vault-config.hcl
COPY init-vault.sh /usr/local/bin/init-vault.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/init-vault.sh /usr/local/bin/entrypoint.sh

# Setup Supervisor to manage processes
RUN echo $'[supervisord]\nnodaemon=true\nuser=root\n\n[program:vault]\ncommand=vault server -config=/vault/config/vault-config.hcl\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0\n\n[program:tor]\ncommand=tor -f /etc/tor/torrc\nuser=tor\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0' > /etc/supervisord.conf

# Setup Tor configuration
RUN echo $'DataDirectory /var/lib/tor\n\
HiddenServiceDir /var/lib/tor/hidden_service/\n\
HiddenServicePort 8200 127.0.0.1:8200\n\
Log notice stdout' > /etc/tor/torrc

EXPOSE 8200

# Entrypoint handles address logging and starting supervisor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
