#!/bin/bash -xe

echo "Creating necessary directories for Solana validator."
echo "IMPORTANT: For optimal performance, it is recommended to mount the following directories to faster storage:"
echo "  - /opt/solana/ledger"
echo "  - /opt/solana/accounts"
echo "  - /opt/solana/snapshots"
echo "Ideally, each directory should be on separate, high-speed disks (e.g., NVMe tmpfs) to reduce I/O contention."

# Create folders that will be mounted
mkdir -pv /opt/solana/ledger
mkdir -pv /opt/solana/accounts
mkdir -pv /opt/solana/snapshots

chown -R solana:solana-users /opt/solana
chmod -R 775 /opt/solana

echo "Directories created. Ensure they are mounted to fast storage before starting the Solana validator."