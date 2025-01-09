# Stage 1: Build
ARG TARGETPLATFORM
FROM --platform=$TARGETPLATFORM python:3.12-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Run
FROM --platform=$TARGETPLATFORM python:3.12-slim AS run

RUN useradd -m -s /bin/bash -g root fritz
USER fritz

COPY --from=build /usr/local /usr/local
COPY --chown=fritz:root static /home/fritz/static
COPY --chown=fritz:root main.py /home/fritz/main.py

EXPOSE 8080
WORKDIR /home/fritz
ENTRYPOINT ["python", "main.py"]
