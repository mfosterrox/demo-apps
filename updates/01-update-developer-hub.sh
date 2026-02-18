#!/usr/bin/env bash
# Update Red Hat Developer Hub (Backstage) to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin
# URL: https://backstage-backstage.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com

set -euo pipefail

NAMESPACE="${NAMESPACE:-rhdh-operator}"
SUBSCRIPTION_NAME="${SUBSCRIPTION_NAME:-rhdh}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating Red Hat Developer Hub (namespace: $NAMESPACE, subscription: $SUBSCRIPTION_NAME) to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  echo "ERROR: Namespace '$NAMESPACE' not found. Is Developer Hub installed?"
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
if [[ -z "$sub" ]]; then
  echo "ERROR: No subscription found in $NAMESPACE. Check subscription name."
  exit 1
fi

name=$(basename "$sub")
echo "--> Patching subscription '$name' to channel: $CHANNEL"
oc patch subscription -n "$NAMESPACE" "$name" --type=merge -p "{\"spec\":{\"channel\":\"$CHANNEL\"}}"

echo "--> Checking for pending InstallPlan..."
for ip in $(oc get installplan -n "$NAMESPACE" -o name 2>/dev/null); do
  if [[ $(oc get "$ip" -n "$NAMESPACE" -o jsonpath='{.spec.approved}') == "false" ]]; then
    echo "    Approving $ip"
    oc patch "$ip" -n "$NAMESPACE" --type=merge -p '{"spec":{"approved":true}}'
  fi
done

echo "==> Red Hat Developer Hub subscription updated. OLM will reconcile; check with: oc get csv -n $NAMESPACE"
