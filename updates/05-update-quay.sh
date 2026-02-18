#!/usr/bin/env bash
# Update Red Hat Quay to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin
# URL: https://quay-4sw8b.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com (quayadmin / MTUzMzQ5)

set -euo pipefail

# quay-operator subscription is often in quay-registry or quay-enterprise
NAMESPACE="${NAMESPACE:-quay-registry}"
SUBSCRIPTION_NAME="${SUBSCRIPTION_NAME:-quay-operator}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating Red Hat Quay (namespace: $NAMESPACE, subscription: $SUBSCRIPTION_NAME) to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | grep -i quay || oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
if [[ -z "$sub" ]]; then
  for ns in quay-registry quay-enterprise openshift-operators; do
    if ! oc get namespace "$ns" &>/dev/null; then continue; fi
    sub=$(oc get subscription -n "$ns" -o name 2>/dev/null | grep -i quay || true)
    if [[ -n "$sub" ]]; then
      NAMESPACE="$ns"
      break
    fi
  done
fi
if [[ -z "$sub" ]]; then
  found=$(oc get subscriptions -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\n"}{end}' 2>/dev/null | grep -i quay | head -1)
  if [[ -n "$found" ]]; then
    NAMESPACE="${found%%$'\t'*}"
    name="${found#*$'\t'}"
    sub="subscription.operators.coreos.com/$name"
  fi
fi
if [[ -z "$sub" ]]; then
  echo "ERROR: No Quay subscription found. Set NAMESPACE= or run: oc get subscription -A | grep -i quay"
  exit 1
fi

if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  echo "ERROR: Namespace '$NAMESPACE' not found. Is Quay installed?"
  exit 1
fi

name=$(basename "$sub")
echo "--> Patching subscription '$name' to channel: $CHANNEL"
oc patch subscription -n "$NAMESPACE" "$name" --type=merge -p "{\"spec\":{\"channel\":\"$CHANNEL\"}}"

echo "--> Checking for pending InstallPlan..."
for ip in $(oc get installplan -n "$NAMESPACE" -o name 2>/dev/null); do
  if [[ $(oc get "$ip" -n "$NAMESPACE" -o jsonpath='{.spec.approved}' 2>/dev/null) == "false" ]]; then
    echo "    Approving $ip"
    oc patch "$ip" -n "$NAMESPACE" --type=merge -p '{"spec":{"approved":true}}'
  fi
done

echo "==> Red Hat Quay subscription updated. Check: oc get csv -n $NAMESPACE"
