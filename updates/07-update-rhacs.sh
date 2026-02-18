#!/usr/bin/env bash
# Update Red Hat Advanced Cluster Security (RHACS) to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin
# URL: https://central-stackrox.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com (admin / MTUzMzQ5)

set -euo pipefail

# RHACS operator is often in rhacs-operator or openshift-operators
NAMESPACE="${NAMESPACE:-rhacs-operator}"
SUBSCRIPTION_NAME="${SUBSCRIPTION_NAME:-rhacs-operator}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating Red Hat Advanced Cluster Security (namespace: $NAMESPACE) to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

if [[ -z "$NAMESPACE" ]] || ! oc get namespace "$NAMESPACE" &>/dev/null; then
  for ns in rhacs-operator stackrox openshift-operators; do
    if oc get subscription -n "$ns" 2>/dev/null | grep -qE 'rhacs|advanced-cluster-security|stackrox'; then
      NAMESPACE="$ns"
      break
    fi
  done
fi
if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  echo "ERROR: Could not find RHACS operator namespace. Set NAMESPACE= manually."
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | grep -iE 'rhacs|acs|stackrox' || oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
if [[ -z "$sub" ]]; then
  echo "ERROR: No RHACS subscription found in $NAMESPACE."
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

echo "==> RHACS subscription updated. Check: oc get csv -n $NAMESPACE"
