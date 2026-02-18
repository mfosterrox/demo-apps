#!/usr/bin/env bash
# Update Red Hat Trusted Profile Analyzer to stable channel on OpenShift
# Prerequisites: oc logged in with cluster-admin
# URL: https://console-trusted-profile-analyzer.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com

set -euo pipefail

# Common namespace names for TPA (trusted-profile-analyzer is typical)
NAMESPACE="${NAMESPACE:-trusted-profile-analyzer}"
SUBSCRIPTION_NAME="${SUBSCRIPTION_NAME:-}"
CHANNEL="${CHANNEL:-stable}"

echo "==> Updating Red Hat Trusted Profile Analyzer (namespace: $NAMESPACE) to channel: $CHANNEL"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

if ! oc get namespace "$NAMESPACE" &>/dev/null; then
  NAMESPACE=$(oc get subscriptions -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\n"}{end}' 2>/dev/null | xargs -I{} sh -c 'oc get sub -n {} -o name 2>/dev/null | grep -qi trusted-profile && echo {}' | head -1)
fi
if [[ -z "$NAMESPACE" ]] || ! oc get namespace "$NAMESPACE" &>/dev/null; then
  NAMESPACE=$(oc get ns -o name 2>/dev/null | sed 's|namespace/||' | xargs -I{} sh -c 'oc get sub -n {} -o jsonpath="{.items[*].metadata.name}" 2>/dev/null | grep -q trusted && echo {}' | head -1)
fi
if [[ -z "$NAMESPACE" ]]; then
  echo "ERROR: Could not find Trusted Profile Analyzer subscription. Set NAMESPACE= and SUBSCRIPTION_NAME= manually."
  exit 1
fi

sub=$(oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | grep -i trusted || oc get subscription -n "$NAMESPACE" -o name 2>/dev/null | head -1)
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

echo "==> Trusted Profile Analyzer subscription updated. Check: oc get csv -n $NAMESPACE"
