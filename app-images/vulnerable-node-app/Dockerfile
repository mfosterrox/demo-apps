# Base image: Debian with Node.js installed
FROM debian:bookworm-slim
# Set environment variables for Node.js and Yarn versions
ENV NODE_VERSION=22.12.0
ENV YARN_VERSION=1.22.22
# Create a node user and group
RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
# Install Node.js, Yarn, and other dependencies
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl gnupg gcc make build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn@"$YARN_VERSION" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
# Switch to the node user
USER node
# Set the working directory for the app
WORKDIR /app
# Copy package files and install dependencies
COPY package*.json ./
RUN npm install
# Copy the source code
COPY . .
# Build overflow binary from overflow.c
COPY overflow.c ./overflow.c
RUN gcc -o overflow overflow.c
# Expose port 3000
EXPOSE 3000
# Command to start the application
CMD ["node", "app.js"]
