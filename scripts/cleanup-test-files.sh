#!/usr/bin/env bash

set -euo pipefail

TEST_DIRECTORY="/var/tmp/azure-monitoring-lab"

if [[ -d "${TEST_DIRECTORY}" ]]; then
  sudo rm -rf "${TEST_DIRECTORY}"
  echo "Temporary monitoring test files removed."
else
  echo "No temporary monitoring test files were found."
fi

echo
echo "Current disk utilization:"
df -h /