# https://github.com/snyk-labs/nodejs-goof
FROM node:18.13.0

LABEL maintainer="Foster <mfoster@redhat.com>"

# Install git for cloning
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src/goof

# Clone the repository
RUN git clone https://github.com/snyk-labs/nodejs-goof.git /tmp/goof && \
    cp -r /tmp/goof/. /usr/src/goof/ && \
    rm -rf /tmp/goof

# Set environment variables to help with native module builds
ENV NODE_OPTIONS="--openssl-legacy-provider"
ENV npm_config_build_from_source=false

# Install dependencies, skipping scripts to avoid segfaults from native module compilation
RUN npm install --legacy-peer-deps --ignore-scripts

# Create directory for extracted files
RUN mkdir -p /tmp/extracted_files

EXPOSE 3001
EXPOSE 9229

ENTRYPOINT ["npm", "start"]
