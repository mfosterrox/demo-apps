./mvnw package
podman build --platform linux/s390x -t quay.io/rhacs-misc/springboot:os390 ./ -f ./Dockerfile.os390
