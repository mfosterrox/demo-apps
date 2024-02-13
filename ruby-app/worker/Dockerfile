FROM governmentpaas/psql

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app
RUN chown -R appuser:appgroup /app

USER 1000

COPY worker.sh worker.sh

CMD ["sh", "worker.sh"]
