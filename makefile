# Define variables
TEAM_NAME := mfoster
VERSION := 0.1.1
APPLICATIONS:= dvwa juice-shop log4shell nodejs-goof-vuln-main rce-exploit rce-http-exploit webgoat frontend payment-processor database
MANIFEST_DIR ?= app-images  

update:
	@echo "Updating image tags in Kubernetes manifests in $(MANIFEST_DIR)"
	@find $(MANIFEST_DIR) -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do \
		echo "Processing $$file"; \
		sed -E 's|\(quay\.io/mfoster/vulnerable-demo-applications:[^:]*:\)[0-9]+$$|\1$(VERSION)|' $$file; \
		echo "Updated image tags in $$file"; \
	done
	@echo "All relevant manifest files in $(MANIFEST_DIR) have been updated to use version: $(VERSION)"

build-images:
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; \
	  	echo "Building $$component..."; \
	  	podman build --platform linux/amd64,linux/arm64 \
	  	-t quay.io/$(TEAM_NAME)/$${component}:$(VERSION) . || exit 1; \
	  	echo "Pushing $$component..."; \
	  	podman push quay.io/$(TEAM_NAME)/$${component}:$(VERSION) || exit 1; \
		); \
	done; \

build:
	@if [ -z "$(COMPONENT)" ]; then \
		echo "Error: Please specify a COMPONENT to build (e.g., make build COMPONENT=example)."; \
		exit 1; \
	fi
	cd app-images/$(COMPONENT); \
	podman build --platform linux/amd64,linux/arm64 \
	-t quay.io/$(TEAM_NAME)/$(COMPONENT):$(VERSION) . ; \
	podman push quay.io/$(TEAM_NAME)/$(COMPONENT):$(VERSION) ;


rm-all-containers:
	podman rm $$(podman ps -a -q)

rm-all-images:
	podman rmi -f $$(podman images -aq)

push-images:
	for component in $(APPLICATIONS); do \
		echo "Pushing $$component..."; \
		podman push quay.io/$(TEAM_NAME)/$${component}:$(VERSION) || exit 1; \
	done; \

build-tag-and-push:
	make build-images
	make push-images

pull:
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; \
		  podman pull quay.io/$(TEAM_NAME)/$${component}:$(VERSION) \
		); \
	done; \
