TEAM_NAME := mfoster
REPO_NAME := vulnerable-demo-applications
VERSION := 0.1

COMPONENTS := damn-vulnerable-graphql-application juice-shop ctf-web-to-system log4shell-vulnerable-app

build-images:
	for component in $(COMPONENTS); do \
		( cd $${component}; docker build -t $(TEAM_NAME)/$(REPO_NAME):$${component} . ); \
	done

tag-images:
	for component in $(COMPONENTS); do \
		docker tag $(TEAM_NAME)/$(REPO_NAME):$${component} quay.io/$(TEAM_NAME)/$(REPO_NAME):$${component}-$(VERSION); \
	done

push-images:
	for component in $(COMPONENTS); do \
		docker push quay.io/$(TEAM_NAME)/$(REPO_NAME):$${component}-$(VERSION); \
	done

rm-all-containers:
	docker rm $$(docker ps -a -q)

rm-all-images:
	docker rmi -f $$(docker images -aq)

build-tag-and-push:
	make build-images
	make tag-images
	make push-images