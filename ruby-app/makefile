TEAM_NAME := mfoster
REPO_NAME := vulnerable-demo-applications
VERSION := 0.1

COMPONENTS := rails-app content-api worker

build-images:
	for component in $(COMPONENTS); do \
		( cd ruby-app/$${component}; docker build -t $(TEAM_NAME)/$(REPO_NAME):$${component} . ); \
	done

tag-images:
	for component in $(COMPONENTS); do \
		docker tag $(TEAM_NAME)/$(REPO_NAME):$${component} quay.io/$(TEAM_NAME)/$(REPO_NAME):$${component}-$(VERSION); \
	done

push-images:
	for component in $(COMPONENTS); do \
		docker push quay.io/$(TEAM_NAME)/$(REPO_NAME):$${component}-$(VERSION); \
	done

build-tag-and-push:
	make build-images
	make tag-images
	make push-images