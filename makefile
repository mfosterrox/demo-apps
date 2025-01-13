# Define variables
TEAM_NAME := mfoster
VERSION := 0.1
APPLICATIONS:= dvwa juice-shop log4shell nodejs-goof-vuln-main rce-exploit rce-http-exploit webgoat frontend payment-processor database
MANIFEST_DIR ?= kubernetes-manifests  

update:
	@echo "Updating image tags in Kubernetes manifests in $(MANIFEST_DIR)"
	@find $(MANIFEST_DIR) -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do \
		echo "Processing $$file"; \
		sed -E 's|\(quay\.io/mfoster/vulnerable-demo-applications:[^:]*:\)[0-9]+$$|\1$(VERSION)|' $$file; \
		echo "Updated image tags in $$file"; \
	done
	@echo "All relevant manifest files in $(MANIFEST_DIR) have been updated to use version: $(VERSION)"

build-images-amd:
	@ARCHITECTURE_OUTPUT=""
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; \
		  docker build --build-arg TARGETPLATFORM=linux/amd64 -t quay.io/$(TEAM_NAME)/$${component}-amd64:$(VERSION) . --push ; \
		); \
	done; \

build-images-arm:
	@ARCHITECTURE_OUTPUT=""
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; \
		  docker buildx build --build-arg TARGETPLATFORM=linux/arm64 -t quay.io/$(TEAM_NAME)/$${component}-arm64:$(VERSION) . --push ; \
		); \
	done; \

push-images-arm:
	for component in $(APPLICATIONS); do \
		docker push quay.io/$(TEAM_NAME)/$${component}-arm64:$(VERSION); \
	done

push-images-amd:
	for component in $(APPLICATIONS); do \
		docker push quay.io/$(TEAM_NAME)/$${component}-amd64:$(VERSION); \
	done

rm-all-containers:
	docker rm $$(docker ps -a -q)

rm-all-images:
	docker rmi -f $$(docker images -aq)

build-tag-and-push-arm:
	make build-images-arm
	make push-images-arm

build-tag-and-push-amd:
	make build-images-amd
	make push-images-amd