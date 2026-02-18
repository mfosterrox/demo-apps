#!/usr/bin/env bash
# Update OpenShift cluster to the latest stable release in the current channel
# Prerequisites: oc logged in as cluster-admin
# Console: https://console-openshift-console.apps.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com
# API: https://api.cluster-4sw8b.4sw8b.sandbox1718.opentlc.com:6443

set -euo pipefail

# Target channel (e.g. stable-4.15, stable-4.16). Leave empty to keep current and only report.
CHANNEL="${CHANNEL:-}"
# Set to "yes" to actually perform the upgrade (otherwise dry-run / report only)
DO_UPGRADE="${DO_UPGRADE:-no}"

echo "==> OpenShift cluster update (stable channel)"

if ! oc whoami &>/dev/null; then
  echo "ERROR: Not logged in to OpenShift. Run 'oc login' first."
  exit 1
fi

current=$(oc get clusterversion version -o jsonpath='{.status.desired.version}' 2>/dev/null || true)
echo "--> Current cluster version: $current"

if [[ -n "$CHANNEL" ]]; then
  echo "--> Setting update channel to: $CHANNEL"
  oc adm upgrade channel "$CHANNEL"
else
  echo "--> Current channel: $(oc get clusterversion version -o jsonpath='{.spec.channel}' 2>/dev/null)"
  echo "    To switch to stable, run: CHANNEL=stable-4.xx $0"
fi

available=$(oc adm upgrade 2>/dev/null | head -20)
echo "--> Available updates:"
echo "$available"

if [[ "${DO_UPGRADE:-no}" != "yes" ]]; then
  echo ""
  echo "==> No upgrade performed (DO_UPGRADE=no). To allow upgrade:"
  echo "    1. Set channel if needed: CHANNEL=stable-4.xx ./08-update-openshift-cluster.sh"
  echo "    2. Then run: DO_UPGRADE=yes ./08-update-openshift-cluster.sh"
  echo "    Or approve the upgrade from the OpenShift Console: Administration -> Cluster Settings -> Channel / Updates"
  exit 0
fi

echo "--> Checking for recommended update..."
recommended=$(oc get clusterversion version -o jsonpath='{.status.availableUpdates[0].version}' 2>/dev/null || true)
if [[ -z "$recommended" ]]; then
  echo "    No pending update available. Cluster is current for the channel."
  exit 0
fi

echo "--> Recommending update to $recommended (cluster will upgrade when nodes are ready)"
oc adm upgrade --to "$recommended" 2>/dev/null || oc adm upgrade --to-latest
echo "==> Upgrade started. Monitor with: oc get clusterversion; watch -n5 oc get nodes"
