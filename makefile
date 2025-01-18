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

build-images:
	docker buildx ls
	docker buildx create --use --name mybuilder
	docker buildx inspect --bootstrap
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; \
	  	docker buildx build --platform linux/amd64,linux/arm64 \
	  	-t quay.io/$(TEAM_NAME)/$(COMPONENT):latest --push \
	  	--cache-from=type=registry,ref=quay.io/$(TEAM_NAME)/$(COMPONENT):cache \
	  	--cache-to=type=registry,ref=quay.io/$(TEAM_NAME)/$(COMPONENT):cache,mode=max . ; \
		); \
	done; \

build:
	@if [ -z "$(COMPONENT)" ]; then \
		echo "Error: Please specify a COMPONENT to build (e.g., make build-image COMPONENT=example)."; \
		exit 1; \
	fi
	@if ! docker buildx inspect mybuilder > /dev/null 2>&1; then \
		echo "Creating builder instance 'mybuilder'."; \
		docker buildx create --use --name mybuilder; \
	else \
		echo "Using existing builder instance 'mybuilder'."; \
	fi
	docker buildx inspect --bootstrap
	cd app-images/$(COMPONENT); \
	docker buildx build --platform linux/amd64,linux/arm64 \
	-t quay.io/$(TEAM_NAME)/$(COMPONENT):latest --push . ;


rm-all-containers:
	docker rm $$(docker ps -a -q)

rm-all-images:
	docker rmi -f $$(docker images -aq)

build-tag-and-push:
	make build-images
	make push-images

pull:
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; \
		  docker pull quay.io/$(TEAM_NAME)/$${component}:latest \
		); \
	done; \
