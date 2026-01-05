FROM node:16-bullseye

WORKDIR /app

# Install build dependencies for native modules (sqlite3, bcrypt)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

RUN chown node /app

COPY . .
RUN chmod u+s ./lookatme
RUN chmod g+s ./lookatme
RUN mv ./bot.code /root/bot.code

# Use --unsafe-perm and increase memory for native module compilation
# Node 16 is more compatible with bcrypt@1.0.3 and sqlite3@4.0.0
ENV NODE_OPTIONS="--max-old-space-size=2048"
# Set npm cache to a writable location and HOME to app directory
ENV NPM_CONFIG_CACHE=/tmp/.npm
ENV HOME=/app
# Create npm cache directory with proper permissions before switching users
RUN mkdir -p /tmp/.npm && chmod 777 /tmp/.npm
# Configure npm to use the writable cache directory
RUN npm config set cache /tmp/.npm --global
# Install node-gyp globally for native module builds
RUN npm install -g node-gyp --unsafe-perm
# Install dependencies - sqlite3 will be built during install with --unsafe-perm
# This ensures native modules are compiled correctly
RUN npm install --no-audit --unsafe-perm || npm install --no-audit --unsafe-perm --legacy-peer-deps

# Verify sqlite3 module directory exists
# Note: We don't try to require() it here as it may cause segfaults during build
# The module will be tested at runtime when the app starts
RUN if [ ! -d "node_modules/sqlite3" ]; then \
        echo "ERROR: sqlite3 module directory not found after npm install" && exit 1; \
    else \
        echo "✓ sqlite3 module directory found"; \
        ls -la node_modules/sqlite3/ | head -5 || true; \
    fi

USER 1000
CMD npm start
