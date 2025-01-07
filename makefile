TEAM_NAME := mfoster
REPO_NAME := vulnerable-demo-applications
VERSION := 0.2

APPLICATIONS:= juice-shop log4shell nodejs-goof-vuln-main rce-exploit rce-http-exploit struts webgoat

build-images:
	for component in $(APPLICATIONS); do \
		( cd app-images/$${component}; docker build -t $(TEAM_NAME)/$(REPO_NAME):$${component} . ); \
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