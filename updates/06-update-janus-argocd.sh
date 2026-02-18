#!/usr/bin/env bash
# Update Janus ArgoCD to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin
# URL: https://argocd-server-janus-argocd.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com (admin / MTUzMzQ5)

set -euo pipefail

NAMESPACE="${NAMESPACE:-janus-argocd}"
SUBSCRIPTION_NAME="${SUBSCRIPTION_NAME:-}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating Janus ArgoCD (namespace: $NAMESPACE) to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  # Try common Argo CD operator namespaces
  for ns in janus-argocd argocd openshift-gitops; do
    if oc get namespace "$ns" &>/dev/null; then
      NAMESPACE="$ns"
      break
    fi
  done
fi
if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  echo "ERROR: Namespace '$NAMESPACE' not found. Set NAMESPACE= to the Argo CD operator namespace."
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
if [[ -z "$sub" ]]; then
  echo "ERROR: No subscription found in $NAMESPACE. List with: oc get subscription -n $NAMESPACE"
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

echo "==> Janus ArgoCD subscription updated. Check: oc get csv -n $NAMESPACE"
