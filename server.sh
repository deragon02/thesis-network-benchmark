#!/usr/bin/env bash
set -Eeuo pipefail

PORT="${1:-5201}"
LOG_DIR="${LOG_DIR:-./logs}"
mkdir -p "$LOG_DIR"

if ! [[ "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1024 || PORT > 65535 )); then
  echo "Invalid port: $PORT" >&2
  exit 2
fi

if ! command -v iperf3 >/dev/null 2>&1; then
  echo "iperf3 is not installed. Run: sudo apt-get install -y iperf3" >&2
  exit 1
fi

LOG_FILE="$LOG_DIR/server-$(date +%Y%m%d-%H%M%S).log"
echo "Starting bounded iperf3 server on port $PORT; stop with Ctrl-C." | tee "$LOG_FILE"
exec iperf3 -s -p "$PORT" --one-off 2>&1 | tee -a "$LOG_FILE"

