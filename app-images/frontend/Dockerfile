FROM python:3.12-alpine AS build

RUN pip install --no-cache-dir httpx psycopg psycopg_binary psycopg_pool starlette sse_starlette uvicorn

#vulnerable packages
RUN pip install --no-cache-dir setuptools==39.1.0
RUN pip install --no-cache-dir Flask==0.5
RUN pip install --no-cache-dir Django==1.11.29
RUN pip install --no-cache-dir requests==2.19.0
RUN pip install --no-cache-dir PyYAML==3.12

FROM python:3.12-alpine AS run

RUN adduser -S fritz -G root
USER fritz

COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --chown=fritz:root static /home/fritz/static
COPY --chown=fritz:root main.py /home/fritz/main.py

EXPOSE 8080
WORKDIR /home/fritz
ENTRYPOINT ["python", "main.py"]
