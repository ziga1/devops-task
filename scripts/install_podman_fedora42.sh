#!/usr/bin/env bash
# rootless podman on fedora 42 — idempotent setup + quick checks
set -euo pipefail

# detect sudo and target user (supports: run as yourself OR via sudo)
SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi
TARGET_USER="${SUDO_USER:-$USER}"

echo "[i] Target user: ${TARGET_USER}"
getent passwd "${TARGET_USER}" >/dev/null || { echo "[!] User not found: ${TARGET_USER}"; exit 1; }

echo "[i] Updating and installing packages…"
$SUDO dnf -y upgrade --refresh
$SUDO dnf -y install \
  podman \
  netavark aardvark-dns \
  slirp4netns fuse-overlayfs \
  uidmap shadow-utils \
  containers-common \
  crun \
  jq || true

# optional - external python based compose - podman v5+ has podman compose built in
if ! podman compose version >/dev/null 2>&1; then
  echo "[i] Installing python3-podman-compose (optional fallback)…"
  $SUDO dnf -y install python3-podman-compose || true
fi

echo "[i] Ensuring subuid/subgid ranges for rootless…"
# prefer usermod if available- fallback to editing files
if $SUDO usermod --help >/dev/null 2>&1; then
  set +e
  $SUDO usermod --add-subuids 100000-165536 --add-subgids 100000-165536 "${TARGET_USER}" 2>/dev/null
  set -e
fi
if ! grep -q "^${TARGET_USER}:" /etc/subuid; then
  echo "${TARGET_USER}:100000:65536" | $SUDO tee -a /etc/subuid >/dev/null
fi
if ! grep -q "^${TARGET_USER}:" /etc/subgid; then
  echo "${TARGET_USER}:100000:65536" | $SUDO tee -a /etc/subgid >/dev/null
fi

echo "[i] Enabling lingering so user services can run without an active session…"
$SUDO loginctl enable-linger "${TARGET_USER}" || true

echo "[i] Basic config sanity…"
# ensure rootless storage uses fuse-overlayfs when appropriate
# (fedora defaults are mostlz correct- this is just a visibility check)
if command -v podman >/dev/null 2>&1; then
  podman info >/tmp/podman-info.json 2>/dev/null || true
fi

echo "----- PODMAN QUICK INFO -----"
podman --version || true
podman info --format '{{json .}}' 2>/dev/null | jq -r '
  {
    rootless: .Host.Rootless,
    cgroupManager: .Host.CgroupManager,
    ociRuntime: .Host.OCIRuntime.Name,
    graphDriver: .Store.GraphDriverName,
    networkBackend: .Host.NetworkBackend
  }' 2>/dev/null || true
echo "-----------------------------"

echo "[i] Compose availability:"
if podman compose version >/dev/null 2>&1; then
  podman compose version || true
else
  podman-compose --version || true
fi

echo
echo "[✓] Done. You can test rootless networking with:"
echo "    podman run --rm quay.io/podman/hello"
echo
echo "[i] If you just edited subuid/subgid, a re-login may be required for the user mappings to apply."
