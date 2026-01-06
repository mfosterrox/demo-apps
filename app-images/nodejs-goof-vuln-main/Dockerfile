# https://github.com/snyk-labs/nodejs-goof
FROM node:18.13.0

LABEL maintainer="Foster <mfoster@redhat.com>"

# Install git for cloning
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for OpenShift compatibility with home directory
RUN groupadd -r nodejs && useradd -r -g nodejs -u 1001 -m -d /home/nodejs nodejs

# Set working directory
WORKDIR /usr/src/goof

# Clone the repository
RUN git clone https://github.com/snyk-labs/nodejs-goof.git /tmp/goof && \
    cp -r /tmp/goof/. /usr/src/goof/ && \
    rm -rf /tmp/goof

# Set environment variables to help with native module builds and npm configuration
ENV NODE_OPTIONS="--openssl-legacy-provider"
ENV npm_config_build_from_source=false
ENV npm_config_cache=/tmp/npm-cache
ENV npm_config_logs_max=10
ENV HOME=/tmp

# Install dependencies, skipping scripts to avoid segfaults from native module compilation
RUN npm install --legacy-peer-deps --ignore-scripts

# Create directories for extracted files and npm cache with proper permissions
RUN mkdir -p /tmp/extracted_files /tmp/npm-cache /.npm /home/nodejs/.npm && \
    chown -R nodejs:nodejs /usr/src/goof /tmp/extracted_files /tmp/npm-cache /.npm /home/nodejs

# Switch to non-root user
USER nodejs

EXPOSE 3001
EXPOSE 9229

ENTRYPOINT ["npm", "start"]
