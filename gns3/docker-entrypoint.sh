#!/bin/bash

set -e;

echo "[ENTRYPOINT] Starting Docker daemon...";
dockerd > /var/log/dockerd.log 2>&1 &
sleep 3;

echo "[ENTRYPOINT] Starting libvirtd...";
/usr/sbin/libvirtd -d;
sleep 2;

virsh list --all || echo "libvirtd not ready";

docker ps || echo "docker ps not ready";

IMAGES_DIR="/root/.local/share/GNS3/docker/images";

for dir in $IMAGES_DIR/*; do
    echo " + $dir";
    if [[ -d "$dir" ]]; then
        echo " + $dir";
        if [[ -f "$dir/Dockerfile" ]] || [[ -f "$dir/dockerfile" ]]; then
       
            image_name=$(basename "$dir");
            echo "➡️  Buildando imagem: $image_name a partir de $dir";
            docker build -t "gns3/$image_name:latest" "$dir";

            if [[ $? -eq 0 ]]; then
                echo "✅ Sucesso: $image_name";
            else
                echo "❌ Falha ao buildar: $image_name";
            fi

        else
            echo "⚠️  Ignorando $dir (sem Dockerfile)";
        fi
    fi
done

docker images || echo "docker images not ready";

echo "[ENTRYPOINT] Starting GNS3 Server...";
exec /root/.local/bin/gns3server --port 3080;
