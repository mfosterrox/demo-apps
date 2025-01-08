# Stage 1: Build
FROM python:3.12-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Run
FROM python:alpine AS run

RUN adduser -S fritz -G root
USER fritz

COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --chown=fritz:root static /home/fritz/static
COPY --chown=fritz:root main.py /home/fritz/main.py

EXPOSE 8080
WORKDIR /home/fritz
ENTRYPOINT ["python", "main.py"]
