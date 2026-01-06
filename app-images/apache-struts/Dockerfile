FROM --platform=linux/amd64 maven:3-jdk-8-slim

# https://github.com/deepfence/apache-struts
LABEL maintainer="Foster <mfoster@redhat.com>"

RUN set -x \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y at netcat strace \
	&& apt-get purge --auto-remove -y \
	&& rm -rf /etc/apt/sources.list.d/* \
	&& rm -rf /var/lib/apt/lists/*

COPY source/main /usr/src/cve-2017-5638/src/main
COPY source/pom.xml /usr/src/cve-2017-5638/

RUN mkdir -p /cve-2017-5638 \
	&& cd /usr/src/cve-2017-5638 \
	&& mvn package \
	&& find /usr/src/cve-2017-5638/target -name "cve-2017-5638-*.jar" ! -name "original-*.jar" -exec cp {} /cve-2017-5638/cve-2017-5638-example.jar \; \
	&& if [ ! -f /cve-2017-5638/cve-2017-5638-example.jar ]; then \
		echo "Error: JAR file not found in target directory"; \
		echo "Files in target directory:"; \
		ls -la /usr/src/cve-2017-5638/target/ || true; \
		exit 1; \
	fi \
	&& rm -rf /usr/src/cve-2017-5638

COPY entry-point.sh /entry-point.sh

RUN set -x \
	&& chmod +x /entry-point.sh

EXPOSE 8080

ENTRYPOINT ["/entry-point.sh"]

