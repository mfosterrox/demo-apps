TEAM_NAME := mfoster
REPO_NAME := vulnerable-demo-applications
VERSION := 0.1

APPLICATIONS:= central-api-manipulator ctf-web-to-system damn-vulnerable-graphql-application juice-shop log4shell rce-exploit rce-http-exploit springboot

build-images:
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; docker build --platform linux/amd64 -t $(TEAM_NAME)/$(REPO_NAME):$${component} . ); \
	done

tag-images:
	for component in $(APPLICATIONS); do \
		docker tag $(TEAM_NAME)/$(REPO_NAME):$${component} quay.io/$(TEAM_NAME)/$(REPO_NAME):$${component}-$(VERSION); \
	done

push-images:
	for component in $(APPLICATIONS); do \
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