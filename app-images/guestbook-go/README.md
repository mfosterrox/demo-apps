# Guestbook Go Application

A simple Go-based guestbook web application based on the [Kubernetes Guestbook Go example](https://github.com/kubernetes/examples/tree/master/web/guestbook-go).

## Overview

This is a multi-tier web application that allows users to sign a guestbook. The application is written in Go and demonstrates basic web application patterns.

## Building the Image

```bash
cd app-images/guestbook-go
podman build -t quay.io/mfoster/guestbook-go:0.1.0 .
```

Or use the makefile:
```bash
make build COMPONENT=guestbook-go
```

## Requirements

- Go 1.21+
- Port 3000 for web access

## Deployment

The Kubernetes manifests are located in `kubernetes-manifests/guestbook-go/`:
- `namespace.yaml` - Creates the guestbook-go namespace
- `deployment-guestbook-go.yaml` - Deployment configuration
- `service-guestbook-go.yaml` - Service exposing port 3000
- `route-guestbook-go.yaml` - OpenShift Route for web access

Deploy with:
```bash
kubectl apply -f kubernetes-manifests/guestbook-go/
```

## References

- Original Repository: https://github.com/kubernetes/examples/tree/master/web/guestbook-go

