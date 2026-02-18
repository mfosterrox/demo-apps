#!/usr/bin/env bash
# Update Red Hat Enterprise Linux Developer Host (bastion) to stable packages
# Run this script ON the RHEL developer host (e.g. via SSH), not from your laptop.
# Host: user@<bastion> (see index.adoc or lab credentials for SSH details)

set -euo pipefail

# Set to "yes" to actually run dnf update (otherwise dry-run)
DO_UPDATE="${DO_UPDATE:-no}"

echo "==> Red Hat Enterprise Linux Developer Host - package update"

if [[ ! -f /etc/redhat-release ]]; then
  echo "WARNING: This does not look like a RHEL system. Run this script on the RHEL developer host."
fi

echo "--> Current system: $(cat /etc/redhat-release 2>/dev/null || uname -a)"
echo "--> Checking for updates..."
sudo dnf check-update -q 2>/dev/null || true
echo ""
sudo dnf list updates -q 2>/dev/null || echo "    (no updates or dnf check-update returned non-zero)"

if [[ "${DO_UPDATE:-no}" != "yes" ]]; then
  echo ""
  echo "==> No packages updated (DO_UPDATE=no). To apply updates on this host, run:"
  echo "    DO_UPDATE=yes ./09-update-rhel-developer-host.sh"
  echo "    Or: sudo dnf update -y"
  exit 0
fi

echo "--> Running: sudo dnf update -y"
sudo dnf update -y
echo "==> RHEL developer host update complete."
