FROM python:alpine AS build

RUN pip install --no-cache-dir starlette uvicorn

FROM python:alpine AS run

RUN adduser -S fritz -G root
USER fritz

COPY --from=build /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.12/site-packages
COPY --chown=fritz:root main.py /home/fritz/main.py

EXPOSE 8080
WORKDIR /home/fritz
ENTRYPOINT ["python", "main.py"]
