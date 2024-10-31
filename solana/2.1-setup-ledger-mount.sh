#!/bin/bash -xe

# Display the block devices
lsblk

# Create a RAID 0 array with the given NVMe drives
mdadm --create --force /dev/md0 --level=0 --raid-devices=8 \
  /dev/nvme0n1 \
  /dev/nvme0n2 \
  /dev/nvme0n3 \
  /dev/nvme0n4 \
  /dev/nvme0n5 \
  /dev/nvme0n6 \
  /dev/nvme0n7 \
  /dev/nvme0n8

# Format the RAID array to ext4
mkfs.ext4 -F /dev/md0

# mount the disk
sudo mount /dev/md0 /opt/solana-ledger
