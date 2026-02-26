FROM ghcr.io/anomalyco/opencode:latest

USER root

# Install R, build tools, and system dependencies
RUN apk add --no-cache \
    R \
    R-dev \
    git \
    openssh-client \
    ca-certificates \
    curl \
    build-base \
    openssl-dev

# Configure R to use the persistent volume and a default CRAN mirror
RUN echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"))' >> /usr/lib/R/etc/Rprofile.site && \
    echo '.libPaths(c("/usr/local/lib/R/site-library", .libPaths()))' >> /usr/lib/R/etc/Rprofile.site

# Entrypoint to fix permissions on start
COPY <<-"EOT" /usr/local/bin/entrypoint.sh
#!/bin/sh
# Fix SSH key permissions for the mounted key
if [ -f "/root/.ssh/id_ed25519" ]; then
    chmod 600 /root/.ssh/id_ed25519
fi

# Ensure the persistent R library folder is writable
mkdir -p /usr/local/lib/R/site-library
chmod -R 777 /usr/local/lib/R/site-library

# Verify sync
if [ -d "/workspaces/R/.git" ]; then
    echo "✅ Successfully synced with ~/Git/R"
else
    echo "⚠️ Warning: .git not found in /workspaces/R. Check your host path."
fi

exec "$@"
EOT

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspaces/R

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh"]