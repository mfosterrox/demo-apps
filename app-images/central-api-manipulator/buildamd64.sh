./mvnw package
podman build --platform linux/amd64 -t quay.io/rhacs-misc/centralapi:1.0 . -f ./Dockerfile.amd64
