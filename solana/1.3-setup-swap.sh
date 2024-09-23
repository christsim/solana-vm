#!/bin/bash -xe

# Display the block devices
lsblk

# create swap
sudo fallocate -l 250G /swapfile
sudo chmod 0600 /swapfile
sudo mkswap /swapfile

# start swap
sudo swapon /swapfile

# save swap mount
sudo cp /etc/fstab /etc/fstab.bak
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

# change swappiness
sudo cat /proc/sys/vm/swappiness
sudo sysctl vm.swappiness=20
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.conf
