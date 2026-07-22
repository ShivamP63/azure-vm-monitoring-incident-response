#!/usr/bin/env bash

set -euo pipefail

DURATION_SECONDS="${1:-480}"
CPU_WORKERS="${2:-$(nproc)}"

echo "Starting CPU load simulation."
echo "Duration: ${DURATION_SECONDS} seconds"
echo "Workers: ${CPU_WORKERS}"
echo "Press Ctrl+C to stop early."

pids=()

cleanup() {
  echo
  echo "Stopping CPU load processes..."

  for pid in "${pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done

  wait 2>/dev/null || true
  echo "CPU load simulation stopped."
}

trap cleanup EXIT INT TERM

for ((worker = 1; worker <= CPU_WORKERS; worker++)); do
  timeout "${DURATION_SECONDS}" bash -c 'while true; do :; done' &
  pids+=("$!")
done

wait