#!/usr/bin/env bash

set -euo pipefail

TEST_DIRECTORY="/var/tmp/azure-monitoring-lab"
TEST_FILE="${TEST_DIRECTORY}/disk-usage-test.bin"
FILE_SIZE="${1:-3G}"

echo "Creating temporary ${FILE_SIZE} test file at:"
echo "${TEST_FILE}"

sudo mkdir -p "${TEST_DIRECTORY}"
sudo fallocate -l "${FILE_SIZE}" "${TEST_FILE}"

echo
echo "Disk utilization after file creation:"
df -h /

echo
echo "The test file is temporary."
echo "Run ./cleanup-test-files.sh to remove it."