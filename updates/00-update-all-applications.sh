#!/usr/bin/env bash
# Run all application update scripts in order (OpenShift operators first; cluster and RHEL last).
# Prerequisites: oc logged in with cluster-admin. For 09, run on the RHEL host or skip.

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

echo "==> Updating all demo applications (01–08 from this machine; 09 run on RHEL host)"
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
echo ""
echo "--> RHEL Developer Host (09): copy 09-update-rhel-developer-host.sh to the bastion and run it there with DO_UPDATE=yes to apply package updates."
echo ""
echo "==> All operator update scripts have been run. Check CSV/operator status per namespace as needed."
