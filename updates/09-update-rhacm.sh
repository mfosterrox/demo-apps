#!/usr/bin/env bash
# Update Red Hat Advanced Cluster Management (RHACM) / open-cluster-management to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin

set -euo pipefail

# RHACM / OCM operator is typically in open-cluster-management or open-cluster-management-hub
NAMESPACE="${NAMESPACE:-open-cluster-management}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating RHACM / open-cluster-management (namespace: $NAMESPACE) to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

if [[ -z "$NAMESPACE" ]] || ! oc get namespace "$NAMESPACE" &>/dev/null; then
  for ns in open-cluster-management open-cluster-management-hub multicluster-engine openshift-operators; do
    if oc get subscription -n "$ns" 2>/dev/null | grep -qE 'advanced-cluster-management|acm|multicluster|open-cluster-management'; then
      NAMESPACE="$ns"
      break
    fi
  done
fi
if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  echo "ERROR: Could not find RHACM / open-cluster-management operator namespace. Set NAMESPACE= manually."
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | grep -iE 'advanced-cluster-management|acm|multicluster|open-cluster-management' || oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
if [[ -z "$sub" ]]; then
  for ns in open-cluster-management open-cluster-management-hub multicluster-engine; do
    sub=$(oc get subscription -n "$ns" -o name 2>/dev/null | grep -iE 'advanced-cluster-management|acm|multicluster|open-cluster-management' || true)
    if [[ -n "$sub" ]]; then
      NAMESPACE="$ns"
      break
    fi
  done
fi
if [[ -z "$sub" ]]; then
  echo "ERROR: No RHACM / open-cluster-management subscription found. Set NAMESPACE= manually."
  exit 1
fi

name=$(basename "$sub")
echo "--> Patching subscription '$name' in $NAMESPACE to channel: $CHANNEL"
oc patch subscription -n "$NAMESPACE" "$name" --type=merge -p "{\"spec\":{\"channel\":\"$CHANNEL\"}}"

echo "--> Checking for pending InstallPlan..."
for ip in $(oc get installplan -n "$NAMESPACE" -o name 2>/dev/null); do
  if [[ $(oc get "$ip" -n "$NAMESPACE" -o jsonpath='{.spec.approved}' 2>/dev/null) == "false" ]]; then
    echo "    Approving $ip"
    oc patch "$ip" -n "$NAMESPACE" --type=merge -p '{"spec":{"approved":true}}'
  fi
done

echo "==> RHACM / open-cluster-management subscription updated. Check: oc get csv -n $NAMESPACE"
