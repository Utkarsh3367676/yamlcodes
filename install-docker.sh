#!/bin/bash
set -e

echo "[Step 1] Updating system and installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

echo "[Step 2] Adding Docker’s official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "[Step 3] Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

echo "[Step 4] Holding current Kubernetes containerd version to prevent overwrite..."
sudo apt-mark hold containerd

echo "[Step 5] Installing Docker Engine (without replacing Kubernetes containerd)..."
sudo apt-get install -y docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin --no-install-recommends

echo "[Step 6] Enabling and starting Docker..."
sudo systemctl enable docker --now

echo "[Step 7] Verifying Docker installation..."
sudo docker run --rm hello-world

echo "[Step 8] Checking container runtimes..."
echo "Kubernetes containerd:"
sudo ctr --address /run/containerd/containerd.sock version || true
echo "Docker containerd:"
sudo ctr --address /var/run/docker/containerd/containerd.sock version || true

echo "[Step 9] Confirming Kubernetes runtime..."
kubectl get nodes -o wide | grep containerd

echo "✅ Docker installed successfully without affecting Kubernetes containerd!"
