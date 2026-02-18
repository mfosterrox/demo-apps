#!/usr/bin/env bash
# Update Red Hat OpenShift Dev Spaces to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin
# URL: https://devspaces.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com (Identity: rhsso, user1)

set -euo pipefail

# Dev Spaces operator is often in openshift-operators or devspaces
NAMESPACE="${NAMESPACE:-}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating Red Hat OpenShift Dev Spaces to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

if [[ -z "$NAMESPACE" ]]; then
  for ns in devspaces openshift-operators; do
    if oc get subscription -n "$ns" 2>/dev/null | grep -qi devspaces; then
      NAMESPACE="$ns"
      break
    fi
  done
fi
if [[ -z "$NAMESPACE" ]]; then
  NAMESPACE=$(oc get subscriptions -A -o json 2>/dev/null | jq -r '.items[] | select(.spec.name | test("devspaces|dev-workspace"; "i")) | .metadata.namespace' | head -1)
fi
if [[ -z "$NAMESPACE" ]]; then
  echo "ERROR: Could not find Dev Spaces subscription. Set NAMESPACE= to the operator namespace."
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | grep -iE 'devspaces|dev-workspace' || oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
if [[ -z "$sub" ]]; then
  echo "ERROR: No subscription found in $NAMESPACE."
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

echo "==> Dev Spaces subscription updated. Check: oc get csv -n $NAMESPACE"
