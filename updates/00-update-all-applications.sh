#!/usr/bin/env bash
# Run all application update scripts in order (OpenShift operators first; cluster and RHACM last).
# Prerequisites: oc logged in with cluster-admin.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

run() {
  local script="$1"
  if [[ ! -x "$script" ]]; then
    chmod +x "$script" 2>/dev/null || true
  fi
  echo ""
  echo "========== $script =========="
  "$script" || { echo "WARNING: $script exited with $?"; }
}

echo "==> Updating all demo applications (01–09)"
run "./01-update-developer-hub.sh"
run "./02-update-gitlab.sh"
run "./03-update-trusted-profile-analyzer.sh"
run "./04-update-devspaces.sh"
run "./05-update-quay.sh"
run "./06-update-janus-argocd.sh"
run "./07-update-rhacs.sh"
echo ""
echo "--> OpenShift cluster (08): run ./08-update-openshift-cluster.sh and set CHANNEL/DO_UPGRADE as needed."
run "./08-update-openshift-cluster.sh"
run "./09-update-rhacm.sh"
echo ""
echo "==> All operator update scripts have been run. Check CSV/operator status per namespace as needed."
