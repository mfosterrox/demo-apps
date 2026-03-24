# Stage 1: Build
FROM python:alpine

# Install necessary dependencies
RUN pip install --no-cache-dir httpx psycopg psycopg_binary psycopg_pool "starlette<1.0.0" sse_starlette uvicorn

