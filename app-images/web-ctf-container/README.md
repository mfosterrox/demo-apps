# Web CTF Container Application

This is a PHP-based web CTF (Capture The Flag) training platform with multiple challenge scenarios based on [HightechSec/web-ctf-container](https://github.com/HightechSec/web-ctf-container).

## Overview

Web CTF Container includes six different web challenge scenarios:
- Admin challenges
- Bypass challenges
- Crack challenges
- Magic challenges
- Numeric challenges
- OTP challenges

## Building the Image

```bash
cd app-images/web-ctf-container
podman build -t quay.io/mfoster/web-ctf-container:0.1.0 .
```

Or use the makefile:
```bash
make build COMPONENT=web-ctf-container
```

## Requirements

- PHP 8.1+ with Apache
- Port 80 for web access

## Deployment

The Kubernetes manifests are located in `kubernetes-manifests/web-ctf-container/`:
- `namespace.yaml` - Creates the web-ctf-container namespace
- `deployment-web-ctf-container.yaml` - Deployment configuration
- `service-web-ctf-container.yaml` - Service exposing port 80
- `route-web-ctf-container.yaml` - OpenShift Route for web access

Deploy with:
```bash
kubectl apply -f kubernetes-manifests/web-ctf-container/
```

## Security Considerations

⚠️ **Warning**: This application contains intentionally vulnerable code for training purposes. Only deploy in isolated demo/test environments.

## References

- Original Repository: https://github.com/HightechSec/web-ctf-container

