# Use the official Vault image as base
FROM hashicorp/vault:latest

# Install Tor, Supervisor, Nginx and SSL
RUN apk add --no-cache tor supervisor bash curl nginx openssl gettext

# Setup directories
RUN mkdir -p /var/lib/tor/hidden_service && \
    mkdir -p /run/nginx && \
    mkdir -p /etc/nginx/templates && \
    chown -R tor:tor /var/lib/tor && \
    chmod 700 /var/lib/tor/hidden_service

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/server.key \
    -out /etc/nginx/server.crt \
    -subj "/C=UN/ST=Privacy/L=Tor/O=Sapphive/CN=vault-over-tor"

# Copy configurations and scripts
COPY config/vault-config.hcl /vault/config/vault-config.hcl
COPY config/nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY init-vault.sh /usr/local/bin/init-vault.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/init-vault.sh /usr/local/bin/entrypoint.sh

# Setup Supervisor to manage processes
RUN echo $'[supervisord]\nnodaemon=true\nuser=root\n\n[program:vault]\ncommand=vault server -config=/vault/config/vault-config.hcl\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0\n\n[program:nginx]\ncommand=nginx -g "daemon off;"\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0\n\n[program:tor]\ncommand=tor -f /etc/tor/torrc\nuser=tor\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0' > /etc/supervisord.conf

# Setup Tor configuration (Forwarding both 80 and 443 to Nginx)
RUN echo $'DataDirectory /var/lib/tor\n\
HiddenServiceDir /var/lib/tor/hidden_service/\n\
HiddenServicePort 80 127.0.0.1:80\n\
HiddenServicePort 443 127.0.0.1:443\n\
Log notice stdout' > /etc/tor/torrc

# Expose Nginx ports
EXPOSE 80 443 8200

# Entrypoint handles address logging and starting supervisor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
