#!/usr/bin/env bash
set -Eeuo pipefail

HOST="${1:-}"
DURATION="${2:-30}"
RATE="${3:-500M}"
MODE="${4:-forward}"
PORT="${PORT:-5201}"
LOG_DIR="${LOG_DIR:-./logs}"

if [[ -z "$HOST" ]]; then
  echo "Usage: $0 SERVER_HOST [duration_seconds<=120] [rate, default 500M] [forward|reverse]" >&2
  exit 2
fi
if ! [[ "$DURATION" =~ ^[0-9]+$ ]] || (( DURATION < 1 || DURATION > 120 )); then
  echo "Duration must be an integer between 1 and 120 seconds." >&2
  exit 2
fi
if [[ "$MODE" != "forward" && "$MODE" != "reverse" ]]; then
  echo "Mode must be forward or reverse." >&2
  exit 2
fi
if ! command -v iperf3 >/dev/null 2>&1; then
  echo "iperf3 is not installed. Run: sudo apt-get install -y iperf3" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/client-$(date +%Y%m%d-%H%M%S).log"
ARGS=( -c "$HOST" -p "$PORT" -u -b "$RATE" -t "$DURATION" -J )
[[ "$MODE" == "reverse" ]] && ARGS+=( -R )

echo "Running bounded iperf3 test: host=$HOST duration=${DURATION}s rate=$RATE mode=$MODE" | tee "$LOG_FILE"
timeout "$((DURATION + 15))" iperf3 "${ARGS[@]}" 2>&1 | tee -a "$LOG_FILE"

