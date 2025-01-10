# Stage 1: Build
FROM python:alpine

# Install necessary dependencies
RUN pip install --no-cache-dir httpx psycopg psycopg_binary psycopg_pool starlette sse_starlette uvicorn

