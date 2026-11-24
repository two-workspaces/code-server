# code-server (VS Code in the browser) for Railway: the official image, the tools most
# projects need on a dev box, and an entrypoint that maps it onto Railway's port and volume.
FROM node:26.13.1-trixie-slim AS node

FROM codercom/code-server:4.146.0
USER root
# Compilers, Python and a few CLI tools. Anything else installs in a terminal with
# `sudo apt-get install`, but only /home/coder survives a redeploy.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential python3 python3-pip python3-venv \
       ripgrep jq unzip zip tmux \
    && rm -rf /var/lib/apt/lists/*
# Node.js LTS with npm and npx, from the official image (same Debian release).
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && node --version && npm --version
COPY drop-file-cache /usr/local/bin/drop-file-cache
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 755 /usr/local/bin/drop-file-cache /usr/local/bin/railway-entrypoint.sh
# Starts as root to prepare the volume, then runs code-server as the coder user.
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
