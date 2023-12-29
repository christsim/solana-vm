#!/bin/bash

# Check if the version number is provided as a command-line argument
if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.7.0"
    exit 1
fi

# Set the version of Node Exporter from the first argument
NODE_EXPORTER_VERSION="$1"

# Detect the architecture
ARCHITECTURE=$(uname -m)
case $ARCHITECTURE in
    x86_64)
        ARCHITECTURE="linux-amd64"
        ;;
    armv6l)
        ARCHITECTURE="linux-armv6"
        ;;
    armv7l)
        ARCHITECTURE="linux-armv7"
        ;;
    aarch64)
        ARCHITECTURE="linux-arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCHITECTURE"
        exit 1
        ;;
esac

# Create a user for node exporter
sudo useradd -rs /bin/false node_exporter

# Download Node Exporter for the detected architecture
cd /tmp
wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.${ARCHITECTURE}.tar.gz"

# Extract the files
tar -xzf "node_exporter-${NODE_EXPORTER_VERSION}.${ARCHITECTURE}.tar.gz"

# Move the binary to /usr/local/bin
sudo mv "node_exporter-${NODE_EXPORTER_VERSION}.${ARCHITECTURE}/node_exporter" /usr/local/bin/

# Clean up the downloaded tar.gz and the extracted folder
rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.${ARCHITECTURE}.tar.gz" "node_exporter-${NODE_EXPORTER_VERSION}.${ARCHITECTURE}"

# Create a systemd service file for Node Exporter
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=127.0.0.1:9100 --web.telemetry-path=/metrics --collector.processes --collector.systemd

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply the new service file
sudo systemctl daemon-reload

# Enable and start Node Exporter service
sudo systemctl enable --now node_exporter

echo "Node Exporter version $NODE_EXPORTER_VERSION for $ARCHITECTURE installed and running on localhost:9100/metrics."
