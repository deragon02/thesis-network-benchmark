#!/usr/bin/env bash
set -Eeuo pipefail

# Bootstrap installer.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/deragon02/thesis-network-benchmark/main/install.sh | sudo bash

REPO_URL="${REPO_URL:-https://github.com/deragon02/thesis-network-benchmark.git}"
INSTALL_DIR="${INSTALL_DIR:-/opt/thesis-network-benchmark}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "این نصب‌کننده باید با دسترسی root اجرا شود؛ از sudo استفاده کنید." >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "این نصب‌کننده فعلاً فقط Debian/Ubuntu را پشتیبانی می‌کند." >&2
  exit 1
fi

echo "[1/3] نصب وابستگی‌های اولیه..."
apt-get update
apt-get install -y ca-certificates git

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "[2/3] به‌روزرسانی پروژه در $INSTALL_DIR ..."
  git -C "$INSTALL_DIR" fetch --depth 1 origin main
  git -C "$INSTALL_DIR" reset --hard origin/main
else
  echo "[2/3] دریافت پروژه در $INSTALL_DIR ..."
  rm -rf "$INSTALL_DIR"
  git clone --depth 1 --branch main "$REPO_URL" "$INSTALL_DIR"
fi

echo "[3/3] اجرای نصب‌کنندهٔ تعاملی..."
exec bash "$INSTALL_DIR/setup.sh"
