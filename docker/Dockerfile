# Use the opencode image as the base
FROM ghcr.io/anomalyco/opencode:latest

# Switch to root to install R and system tools
USER root

# Clean installation of R and dependencies
RUN apk add --no-cache \
    R \
    R-dev \
    git \
    openssh-client \
    ca-certificates \
    curl

# Create a clean entrypoint script
# 1. Sets SSH permissions
# 2. Clones the repo if the volume is empty
RUN printf '#!/bin/sh\n\
if [ -f "/root/.ssh/id_ed25519" ]; then\n\
    chmod 600 /root/.ssh/id_ed25519\n\
fi\n\
if [ ! -d "/workspaces/R/.git" ]; then\n\
    echo "Cloning repository..."\n\
    git clone -b feat/maMDP git@github.com:OliveiraEdu/d-OSPv2.git /workspaces/R\n\
fi\n\
exec "$@"' > /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspaces/R

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh"]