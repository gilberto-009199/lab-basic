#!/bin/bash
set -e

echo "[ENTRYPOINT] Starting Docker daemon..."
dockerd > /var/log/dockerd.log 2>&1 &
sleep 3

echo "[ENTRYPOINT] Starting libvirtd..."
/usr/sbin/libvirtd -d
sleep 2

virsh list --all || echo "libvirtd not ready"

docker ps || echo "docker ps not ready"

echo "[ENTRYPOINT] Starting GNS3 Server..."
exec /root/.local/bin/gns3server --port 3080
