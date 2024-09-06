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

mkdir -pv /opt/solana

# mount the disk
sudo mount /dev/md0 /opt/solana


# setup swap
sudo fallocate -l 250G /swapfile
sudo chmod 0600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
sudo cat /proc/sys/vm/swappiness
sudo sysctl vm.swappiness=20
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf

