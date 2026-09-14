#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PORT="${PORT:-5201}"

if [[ "${EUID}" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "این نصب‌کننده فعلاً فقط Debian/Ubuntu را پشتیبانی می‌کند." >&2
  exit 1
fi

echo "[1/3] نصب وابستگی‌ها..."
$SUDO apt-get update
$SUDO apt-get install -y iperf3 coreutils

$SUDO chmod +x "$PROJECT_DIR/server.sh" "$PROJECT_DIR/client.sh"

read -r -p "نقش این سرور را انتخاب کنید (1=مقصد آلمان، 2=مبدأ ایران): " ROLE

case "$ROLE" in
  1)
    read -r -p "پورت iperf3 [5201]: " INPUT_PORT
    PORT="${INPUT_PORT:-5201}"
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1024 || PORT > 65535 )); then
      echo "پورت نامعتبر است." >&2
      exit 2
    fi
    echo "سرور مقصد آماده می‌شود. این سرویس فقط یک اتصال را می‌پذیرد و سپس متوقف می‌شود."
    echo "در ترمینال دیگر یا روی سرور مبدأ اجرا کنید:"
    echo "  ./client.sh DESTINATION_IP 30 500M"
    exec "$PROJECT_DIR/server.sh" "$PORT"
    ;;
  2)
    read -r -p "آدرس IP یا دامنهٔ سرور مقصد: " DEST_HOST
    [[ -n "$DEST_HOST" ]] || { echo "آدرس مقصد الزامی است." >&2; exit 2; }
    read -r -p "مدت آزمایش برحسب ثانیه (1 تا 120) [30]: " DURATION
    DURATION="${DURATION:-30}"
    read -r -p "نرخ هدف UDP [500M]: " RATE
    RATE="${RATE:-500M}"
    read -r -p "جهت آزمایش (1=مبدأ به مقصد، 2=معکوس) [1]: " DIRECTION
    DIRECTION="${DIRECTION:-1}"
    if [[ "$DIRECTION" == "2" ]]; then
      MODE="reverse"
    elif [[ "$DIRECTION" == "1" ]]; then
      MODE="forward"
    else
      echo "جهت نامعتبر است." >&2
      exit 2
    fi
    exec "$PROJECT_DIR/client.sh" "$DEST_HOST" "$DURATION" "$RATE" "$MODE"
    ;;
  *)
    echo "انتخاب نامعتبر است؛ فقط 1 یا 2 مجاز است." >&2
    exit 2
    ;;
esac
