#!/usr/bin/env bash
# Fedora 42 — Rootless Podman setup (idempotent)
# Installs Podman + helpers, ensures subuid/subgid, enables lingering,
# checks cgroup v2, and prints sanity checks.

set -euo pipefail

# ---- Settings (keep it simple) ---------------------------------------------
DEFAULT_SUB_RANGE_START=100000
DEFAULT_SUB_RANGE_SIZE=65536

TARGET_USER="${SUDO_USER:-$USER}"

if [[ "$TARGET_USER" == "root" ]]; then
  echo "❌ Please run as your normal user (with sudo), not as root."
  echo "   Example:   sudo -E bash scripts/install_podman_fedora42.sh"
  exit 1
fi

echo "==> Target user: $TARGET_USER"

# ---- Packages ---------------------------------------------------------------
echo "==> Installing Podman and helpers…"
sudo dnf -y install \
  podman podman-compose \
  slirp4netns fuse-overlayfs aardvark-dns \
  shadow-utils \
  curl jq procps-ng >/dev/null

# Basic tools we rely on:
command -v podman >/dev/null || { echo "❌ podman not installed"; exit 1; }
command -v newuidmap >/dev/null || { echo "❌ newuidmap missing (uidmap)"; exit 1; }
command -v newgidmap >/dev/null || { echo "❌ newgidmap missing (uidmap)"; exit 1; }

# ---- subuid/subgid ----------------------------------------------------------
add_subid_if_missing() {
  local file="$1" user="$2"
  sudo touch "$file"
  if ! sudo grep -q "^${user}:" "$file"; then
    echo "==> Adding ${user}:${DEFAULT_SUB_RANGE_START}:${DEFAULT_SUB_RANGE_SIZE} to $file"
    echo "${user}:${DEFAULT_SUB_RANGE_START}:${DEFAULT_SUB_RANGE_SIZE}" | sudo tee -a "$file" >/dev/null
  else
    echo "==> $file already contains a range for ${user} (ok)"
  fi
}
echo "==> Ensuring subuid/subgid ranges…"
add_subid_if_missing /etc/subuid "$TARGET_USER"
add_subid_if_missing /etc/subgid "$TARGET_USER"

# ---- Lingering (allows user services without active login) ------------------
echo "==> Enabling systemd lingering for ${TARGET_USER} (ok if already enabled)…"
sudo loginctl enable-linger "$TARGET_USER" >/dev/null || true

# ---- cgroup v2 check (Fedora 42 defaults to v2; we just verify) -----------
CGTYPE=$(stat -fc %T /sys/fs/cgroup || echo unknown)
if [[ "$CGTYPE" == "cgroup2fs" ]]; then
  echo "==> cgroup v2 is active."
else
  echo "⚠  cgroup v2 not active (type=$CGTYPE)."
  echo "   If you need it: sudo grubby --update-kernel=ALL --args='systemd.unified_cgroup_hierarchy=1'"
  echo "   Then reboot the VM."
fi

# ---- Minimal podman config dir (harmless if already there) ------------------
mkdir -p "${HOME}/.config/containers"

# ---- Quick checks -----------------------------------------------------------
echo "==> Running quick checks…"
echo "---- podman version ----"
podman --version || true

echo "---- podman info (rootless, cgroup) ----"
podman info --format 'Rootless={{.Host.Security.Rootless}}  Cgroup={{.Host.CgroupVersion}}  Net={{.Host.NetworkBackend}}' || true

echo "---- subuid/subgid entries ----"
grep -m1 "^${TARGET_USER}:" /etc/subuid || echo "no subuid entry?"
grep -m1 "^${TARGET_USER}:" /etc/subgid || echo "no subgid entry?"

echo "---- lingering status ----"
loginctl show-user "$TARGET_USER" 2>/dev/null | awk -F= '/^Linger=/ {print "Linger="$2}'

echo "---- rootless run test (alpine:3) ----"
if podman run --rm --pull=always docker.io/library/alpine:3 sh -c 'echo ok'; then
  echo "✅ rootless container ran successfully."
else
  echo "❌ rootless run failed (network/registry issue?). Try again later."
fi

echo
echo "=== SUMMARY ==="
echo "User:        $TARGET_USER"
echo "cgroup type: $(stat -fc %T /sys/fs/cgroup 2>/dev/null)"
echo "subuid:      $(grep -m1 ^${TARGET_USER}: /etc/subuid | cut -d: -f2- || echo missing)"
echo "subgid:      $(grep -m1 ^${TARGET_USER}: /etc/subgid | cut -d: -f2- || echo missing)"
echo "Linger:      $(loginctl show-user $TARGET_USER 2>/dev/null | awk -F= '/^Linger=/ {print $2}')"
echo
echo "Done. If you just changed subuid/subgid or cgroup settings, a re-login/reboot may help."
