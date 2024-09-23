#!/bin/bash -xe

# Display the block devices
lsblk

# Create a RAID 0 array for the given NVMe drives for solana-accounts
mdadm --create --force /dev/md1 --level=0 --raid-devices=2 \
        /dev/nvme2n1 \
        /dev/nvme3n1

# Format the RAID array to ext4
mkfs.ext4 -F /dev/md1

mkdir -pv /mnt/disk2

# mount the disk
sudo mount /dev/md1 /mnt/disk2

# create solana-accounts dir and set permissions
sudo mkdir -pv /mnt/disk2/solana-accounts
sudo chown solana:solana -R /mnt/disk2/solana-accounts
sudo chmod 0775 -R /mnt/disk2/solana-accounts

# mount /mnt/disk2/solana-accounts unto /opt/solana-accounts
sudo mkdir -pv /opt/solana-accounts
sudo mount --bind /mnt/disk2/solana-accounts /opt/solana-accounts

# add mounts to fstab
sudo cp /etc/fstab /etc/fstab.bak
echo "/dev/md1 /mnt/disk2 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "/mnt/disk2/solana-accounts /opt/solana-accounts none bind 0 0" | sudo tee -a /etc/fstab
