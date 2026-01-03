#!/bin/sh
set -eu

# Attempts to perform network scanning from within a pod
# This simulates lateral movement and reconnaissance

namespace="${1:-frontend}"
target_namespace="${2:-backend}"

echo "[ATTACK] Network Scanning Attack"
echo "[INFO] Source namespace: $namespace"
echo "[INFO] Target namespace: $target_namespace"

# Step 1: Find a pod to use for scanning
pod_name=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$pod_name" ]; then
    echo "[ERROR] No pods found in namespace $namespace"
    exit 1
fi

echo "[INFO] Using pod: $pod_name"

# Step 2: Get cluster IP range (common Kubernetes CIDRs)
echo "[ATTACK] Attempting to discover cluster network topology..."

# Step 3: Scan Kubernetes service IPs
echo "[ATTACK] Scanning Kubernetes service IPs..."
kubectl get svc -n "$target_namespace" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.clusterIP}{"\n"}{end}' 2>/dev/null | while read svc_name svc_ip; do
    if [ -n "$svc_ip" ] && [ "$svc_ip" != "None" ]; then
        echo "[SCAN] Testing service: $svc_name ($svc_ip)"
        # Try to connect to service
        kubectl exec -n "$namespace" "$pod_name" -- sh -c "timeout 2 nc -zv $svc_ip 8080 2>&1 || timeout 2 nc -zv $svc_ip 80 2>&1 || timeout 2 nc -zv $svc_ip 443 2>&1" 2>/dev/null || true
    fi
done

# Step 4: Try to discover pods via DNS
echo "[ATTACK] Attempting DNS enumeration..."
kubectl get pods -n "$target_namespace" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null | while read target_pod; do
    if [ -n "$target_pod" ]; then
        fqdn="$target_pod.$target_namespace.svc.cluster.local"
        echo "[SCAN] Resolving DNS: $fqdn"
        kubectl exec -n "$namespace" "$pod_name" -- nslookup "$fqdn" 2>/dev/null || \
        kubectl exec -n "$namespace" "$pod_name" -- getent hosts "$fqdn" 2>/dev/null || true
    fi
done

# Step 5: Port scanning common Kubernetes ports
echo "[ATTACK] Port scanning common Kubernetes services..."
for port in 443 6443 2379 2380 10250 10255 10259 10257; do
    echo "[SCAN] Testing port $port on kubernetes.default.svc.cluster.local"
    kubectl exec -n "$namespace" "$pod_name" -- timeout 2 sh -c "echo > /dev/tcp/kubernetes.default.svc.cluster.local/$port" 2>/dev/null && \
        echo "[OPEN] Port $port is open" || true
done

# Step 6: Try to access Kubernetes API server
echo "[ATTACK] Attempting to access Kubernetes API server..."
kubectl exec -n "$namespace" "$pod_name" -- curl -k https://kubernetes.default.svc.cluster.local/api/v1/namespaces 2>/dev/null | head -c 200 && echo "..." || echo "[BLOCKED] API server access denied"

# Step 7: Try to access etcd (if accessible)
echo "[ATTACK] Attempting to access etcd..."
kubectl exec -n "$namespace" "$pod_name" -- curl -k https://etcd.kube-system.svc.cluster.local:2379/version 2>/dev/null || echo "[BLOCKED] etcd not accessible"

echo "[COMPLETE] Network scanning attack finished"

