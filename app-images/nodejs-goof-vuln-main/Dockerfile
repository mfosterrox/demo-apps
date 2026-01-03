# FROM node:6-stretch
FROM node:18.13.0

RUN mkdir /usr/src/goof
RUN mkdir /tmp/extracted_files
COPY . /usr/src/goof
WORKDIR /usr/src/goof

# Set environment variables to help with native module builds
ENV NODE_OPTIONS="--openssl-legacy-provider"
ENV npm_config_build_from_source=false

# Install dependencies, skipping scripts to avoid segfaults from native module compilation
RUN npm install --legacy-peer-deps --ignore-scripts
EXPOSE 3001
EXPOSE 9229
ENTRYPOINT ["npm", "start"]
