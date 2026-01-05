# Define variables
TEAM_NAME := mfoster
VERSION := 0.2.1
APPLICATIONS:= ctf-web-to-system dvwa dvwa-hummingbird frontend juice-shop log4shell nodejs-goof-vuln-main payment-processor rce-exploit rce-http-exploit webgoat
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
	@echo "========================================================="
	@echo "Starting build process for all applications..."
	@echo "========================================================="
	@SUCCESSFUL_BUILDS=""; \
	FAILED_BUILDS=""; \
	SKIPPED_BUILDS=""; \
	TOTAL=0; \
	SUCCESS=0; \
	FAILED=0; \
	SKIPPED=0; \
	for component in $(APPLICATIONS); do \
		TOTAL=$$((TOTAL + 1)); \
	done; \
	TOTAL_COUNT=$$TOTAL; \
	TOTAL=0; \
	for component in $(APPLICATIONS); do \
		TOTAL=$$((TOTAL + 1)); \
		echo ""; \
		IMAGE_NAME="quay.io/$(TEAM_NAME)/$${component}:$(VERSION)"; \
		DOCKERFILE="app-images/$${component}/Dockerfile"; \
		SHOULD_BUILD=false; \
		if ! podman image exists $$IMAGE_NAME >/dev/null 2>&1; then \
			SHOULD_BUILD=true; \
			echo "Building $$component ($$TOTAL/$$TOTAL_COUNT)... (image does not exist)"; \
		elif [ -f "$$DOCKERFILE" ]; then \
			IMAGE_CREATED=$$(podman image inspect $$IMAGE_NAME --format '{{.Created}}' 2>/dev/null || echo ""); \
			if [ -n "$$IMAGE_CREATED" ]; then \
				IMAGE_TIME=$$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('$$IMAGE_CREATED'.replace('Z', '+00:00')).timestamp()))" 2>/dev/null || echo "0"); \
				DOCKERFILE_TIME=$$(stat -c %Y "$$DOCKERFILE" 2>/dev/null || stat -f %m "$$DOCKERFILE" 2>/dev/null || echo "0"); \
				if [ "$$DOCKERFILE_TIME" -gt "$$IMAGE_TIME" ] 2>/dev/null && [ "$$IMAGE_TIME" != "0" ]; then \
					SHOULD_BUILD=true; \
					echo "Building $$component ($$TOTAL/$$TOTAL_COUNT)... (Dockerfile is newer than image)"; \
				fi; \
			fi; \
		fi; \
		if [ "$$SHOULD_BUILD" = "false" ]; then \
			SKIPPED=$$((SKIPPED + 1)); \
			SKIPPED_BUILDS="$$SKIPPED_BUILDS $$component"; \
			echo "⊘ Skipping $$component ($$TOTAL/$$TOTAL_COUNT) - image is up to date"; \
			echo "  Image: $$IMAGE_NAME"; \
		else \
			PLATFORM="linux/amd64"; \
			if ( cd app-images/$${component}; \
				podman build --platform $$PLATFORM \
				-t $$IMAGE_NAME . ); then \
				SUCCESS=$$((SUCCESS + 1)); \
				SUCCESSFUL_BUILDS="$$SUCCESSFUL_BUILDS $$component"; \
				echo "✓ Successfully built $$component"; \
			else \
				FAILED=$$((FAILED + 1)); \
				FAILED_BUILDS="$$FAILED_BUILDS $$component"; \
				echo "✗ Failed to build $$component"; \
			fi; \
		fi; \
	done; \
	echo ""; \
	echo "========================================================="; \
	echo "Build Summary"; \
	echo "========================================================="; \
	echo "Total components processed: $$TOTAL"; \
	echo "Successful builds: $$SUCCESS"; \
	echo "Skipped (already exist): $$SKIPPED"; \
	echo "Failed builds: $$FAILED"; \
	echo ""; \
	if [ -n "$$SUCCESSFUL_BUILDS" ]; then \
		echo "✓ Successfully built:"; \
		for component in $$SUCCESSFUL_BUILDS; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	if [ -n "$$SKIPPED_BUILDS" ]; then \
		echo "⊘ Skipped (already exist):"; \
		for component in $$SKIPPED_BUILDS; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	if [ -n "$$FAILED_BUILDS" ]; then \
		echo "✗ Failed builds:"; \
		for component in $$FAILED_BUILDS; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	echo "========================================================="; \
	if [ $$FAILED -gt 0 ]; then \
		echo "Build completed with errors. Some builds failed."; \
		exit 1; \
	else \
		echo "All builds completed successfully!"; \
	fi

build:
	@if [ -z "$(COMPONENT)" ]; then \
		echo "Error: Please specify a COMPONENT to build (e.g., make build COMPONENT=example)."; \
		exit 1; \
	fi
	@IMAGE_NAME="quay.io/$(TEAM_NAME)/$(COMPONENT):$(VERSION)"; \
	DOCKERFILE="app-images/$(COMPONENT)/Dockerfile"; \
	SHOULD_BUILD=false; \
	if ! podman image exists $$IMAGE_NAME >/dev/null 2>&1; then \
		SHOULD_BUILD=true; \
		echo "========================================================="; \
		echo "Building component: $(COMPONENT)"; \
		echo "========================================================="; \
		echo "Reason: Image does not exist"; \
	elif [ -f "$$DOCKERFILE" ]; then \
		IMAGE_CREATED=$$(podman image inspect $$IMAGE_NAME --format '{{.Created}}' 2>/dev/null || echo ""); \
		if [ -n "$$IMAGE_CREATED" ]; then \
			IMAGE_TIME=$$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('$$IMAGE_CREATED'.replace('Z', '+00:00')).timestamp()))" 2>/dev/null || echo "0"); \
			DOCKERFILE_TIME=$$(stat -c %Y "$$DOCKERFILE" 2>/dev/null || stat -f %m "$$DOCKERFILE" 2>/dev/null || echo "0"); \
			if [ "$$DOCKERFILE_TIME" -gt "$$IMAGE_TIME" ] 2>/dev/null && [ "$$IMAGE_TIME" != "0" ]; then \
				SHOULD_BUILD=true; \
				echo "========================================================="; \
				echo "Building component: $(COMPONENT)"; \
				echo "========================================================="; \
				echo "Reason: Dockerfile is newer than image"; \
			fi; \
		fi; \
	fi; \
	if [ "$$SHOULD_BUILD" = "false" ]; then \
		echo "========================================================="; \
		echo "Image already exists locally: $(COMPONENT)"; \
		echo "========================================================="; \
		echo "⊘ Skipping build - image is up to date"; \
		echo "Image: $$IMAGE_NAME"; \
		echo "========================================================="; \
	else \
		PLATFORM="linux/amd64"; \
		if ( cd app-images/$(COMPONENT); \
			podman build --platform $$PLATFORM \
			-t $$IMAGE_NAME . ); then \
			echo ""; \
			echo "========================================================="; \
			echo "✓ Successfully built $(COMPONENT)"; \
			echo "Image: $$IMAGE_NAME"; \
			echo "========================================================="; \
		else \
			echo ""; \
			echo "========================================================="; \
			echo "✗ Failed to build $(COMPONENT)"; \
			echo "========================================================="; \
			exit 1; \
		fi; \
	fi


rm-all-containers:
	podman rm $$(podman ps -a -q)

rm-all-images:
	podman rmi -f $$(podman images -aq)

build-tag-and-push:
	make build-images
	make push-images

pull:
	@echo "========================================================="
	@echo "Starting pull process for all applications..."
	@echo "========================================================="
	@SUCCESSFUL_PULLS=""; \
	FAILED_PULLS=""; \
	TOTAL=0; \
	SUCCESS=0; \
	FAILED=0; \
	for component in $(APPLICATIONS); do \
		TOTAL=$$((TOTAL + 1)); \
	done; \
	TOTAL_COUNT=$$TOTAL; \
	TOTAL=0; \
	for component in $(APPLICATIONS); do \
		TOTAL=$$((TOTAL + 1)); \
		echo ""; \
		echo "Pulling $$component ($$TOTAL/$$TOTAL_COUNT)..."; \
		if podman pull quay.io/$(TEAM_NAME)/$${component}:$(VERSION); then \
			SUCCESS=$$((SUCCESS + 1)); \
			SUCCESSFUL_PULLS="$$SUCCESSFUL_PULLS $$component"; \
			echo "✓ Successfully pulled $$component"; \
		else \
			FAILED=$$((FAILED + 1)); \
			FAILED_PULLS="$$FAILED_PULLS $$component"; \
			echo "✗ Failed to pull $$component"; \
		fi; \
	done; \
	echo ""; \
	echo "========================================================="; \
	echo "Pull Summary"; \
	echo "========================================================="; \
	echo "Total pulls attempted: $$TOTAL"; \
	echo "Successful pulls: $$SUCCESS"; \
	echo "Failed pulls: $$FAILED"; \
	echo ""; \
	if [ -n "$$SUCCESSFUL_PULLS" ]; then \
		echo "✓ Successful pulls:"; \
		for component in $$SUCCESSFUL_PULLS; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	if [ -n "$$FAILED_PULLS" ]; then \
		echo "✗ Failed pulls:"; \
		for component in $$FAILED_PULLS; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	echo "========================================================="; \
	if [ $$FAILED -gt 0 ]; then \
		echo "Pull completed with errors. Some pulls failed."; \
		exit 1; \
	else \
		echo "All pulls completed successfully!"; \
	fi

push-images:
	@echo "========================================================="
	@echo "Starting push process for all applications..."
	@echo "========================================================="
	@SUCCESSFUL_PUSHES=""; \
	FAILED_PUSHES=""; \
	TOTAL=0; \
	SUCCESS=0; \
	FAILED=0; \
	for component in $(APPLICATIONS); do \
		TOTAL=$$((TOTAL + 1)); \
	done; \
	TOTAL_COUNT=$$TOTAL; \
	TOTAL=0; \
	for component in $(APPLICATIONS); do \
		TOTAL=$$((TOTAL + 1)); \
		echo ""; \
		echo "Pushing $$component ($$TOTAL/$$TOTAL_COUNT)..."; \
		if podman push quay.io/$(TEAM_NAME)/$${component}:$(VERSION); then \
			SUCCESS=$$((SUCCESS + 1)); \
			SUCCESSFUL_PUSHES="$$SUCCESSFUL_PUSHES $$component"; \
			echo "✓ Successfully pushed $$component"; \
		else \
			FAILED=$$((FAILED + 1)); \
			FAILED_PUSHES="$$FAILED_PUSHES $$component"; \
			echo "✗ Failed to push $$component"; \
		fi; \
	done; \
	echo ""; \
	echo "========================================================="; \
	echo "Push Summary"; \
	echo "========================================================="; \
	echo "Total pushes attempted: $$TOTAL"; \
	echo "Successful pushes: $$SUCCESS"; \
	echo "Failed pushes: $$FAILED"; \
	echo ""; \
	if [ -n "$$SUCCESSFUL_PUSHES" ]; then \
		echo "✓ Successful pushes:"; \
		for component in $$SUCCESSFUL_PUSHES; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	if [ -n "$$FAILED_PUSHES" ]; then \
		echo "✗ Failed pushes:"; \
		for component in $$FAILED_PUSHES; do \
			echo "  - $$component"; \
		done; \
		echo ""; \
	fi; \
	echo "========================================================="; \
	if [ $$FAILED -gt 0 ]; then \
		echo "Push completed with errors. Some pushes failed."; \
		exit 1; \
	else \
		echo "All pushes completed successfully!"; \
	fi

push:
	@if [ -z "$(COMPONENT)" ]; then \
		echo "Error: Please specify a COMPONENT to push (e.g., make push COMPONENT=example)."; \
		exit 1; \
	fi
	@echo "========================================================="
	@echo "Pushing component: $(COMPONENT)"
	@echo "========================================================="
	@if podman push quay.io/$(TEAM_NAME)/$(COMPONENT):$(VERSION); then \
		echo ""; \
		echo "========================================================="; \
		echo "✓ Successfully pushed $(COMPONENT)"; \
		echo "Image: quay.io/$(TEAM_NAME)/$(COMPONENT):$(VERSION)"; \
		echo "========================================================="; \
	else \
		echo ""; \
		echo "========================================================="; \
		echo "✗ Failed to push $(COMPONENT)"; \
		echo "========================================================="; \
		exit 1; \
	fi
