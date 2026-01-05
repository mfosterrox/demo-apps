FROM node:22 AS installer
COPY . /juice-shop
WORKDIR /juice-shop
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm i -g typescript ts-node
# Install dependencies without running postinstall script (which builds frontend)
RUN npm install --omit=dev --unsafe-perm --ignore-scripts
# Install frontend dependencies separately
RUN cd frontend && npm install --legacy-peer-deps && cd .. || (echo "ERROR: Frontend install failed" && exit 1)
# Build frontend explicitly - must succeed
RUN npm run build:frontend || (echo "ERROR: Frontend build failed" && exit 1)
# Verify frontend build output exists
RUN test -f frontend/dist/frontend/index.html || (echo "ERROR: frontend/dist/frontend/index.html missing" && exit 1)
RUN test -f frontend/dist/frontend/main.js || (echo "ERROR: frontend/dist/frontend/main.js missing" && exit 1)
RUN test -f frontend/dist/frontend/styles.css || (echo "ERROR: frontend/dist/frontend/styles.css missing" && exit 1)
RUN test -f frontend/dist/frontend/runtime.js || (echo "ERROR: frontend/dist/frontend/runtime.js missing" && exit 1)
RUN test -f frontend/dist/frontend/vendor.js || (echo "ERROR: frontend/dist/frontend/vendor.js missing" && exit 1)
RUN test -f frontend/dist/frontend/polyfills.js || (echo "ERROR: frontend/dist/frontend/polyfills.js missing" && exit 1)
# Build server - must succeed
RUN npm run build:server || (echo "ERROR: Server build failed" && exit 1)
RUN npm dedupe --omit=dev
RUN rm -rf frontend/node_modules
RUN rm -rf frontend/.angular
RUN rm -rf frontend/src/assets
RUN mkdir logs
RUN chown -R 65532 logs
RUN chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/
RUN chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/
RUN rm data/chatbot/botDefaultTrainingData.json || true
RUN rm ftp/legal.md || true
RUN rm i18n/*.json || true

ARG CYCLONEDX_NPM_VERSION=latest
RUN npm install -g @cyclonedx/cyclonedx-npm@$CYCLONEDX_NPM_VERSION
RUN npm run sbom

FROM gcr.io/distroless/nodejs22-debian12
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.title="OWASP Juice Shop" \
    org.opencontainers.image.description="Probably the most modern and sophisticated insecure web application" \
    org.opencontainers.image.authors="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.vendor="Open Worldwide Application Security Project" \
    org.opencontainers.image.documentation="https://help.owasp-juice.shop" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="19.1.1" \
    org.opencontainers.image.url="https://owasp-juice.shop" \
    org.opencontainers.image.source="https://github.com/juice-shop/juice-shop" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE
WORKDIR /juice-shop
COPY --from=installer --chown=65532:0 /juice-shop .
USER 65532
EXPOSE 3000
CMD ["/juice-shop/build/app.js"]
