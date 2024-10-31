#!/bin/bash -xe

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please run it with sudo or as root user."
  exit 1
fi

# Check if the size argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <tmpfs_size>"
  echo "Example: $0 350G"
  echo "Recommended minimum size for Solana accounts tmpfs: 350G"
  exit 1
fi

# Set tmpfs size from argument
TMPFS_SIZE="$1"

# Set mount directory
MOUNT_DIR="/opt/solana/accounts"

# Check if the mount directory exists and contains data
if [ -d "$MOUNT_DIR" ] && [ "$(ls -A "$MOUNT_DIR")" ]; then
  read -p "$MOUNT_DIR exists and contains data. Do you want to delete all data in this directory before mounting tmpfs? (y/n): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deleting all data in $MOUNT_DIR..."
    rm -rf "$MOUNT_DIR"/*
  else
    echo "Aborting operation. Please empty the directory or choose a different mount point."
    exit 1
  fi
fi

# Create the mount directory if it doesn't exist
echo "Creating mount directory at $MOUNT_DIR if it does not exist..."
mkdir -pv "$MOUNT_DIR"

# Mount tmpfs to the directory
echo "Mounting tmpfs of size $TMPFS_SIZE to $MOUNT_DIR..."
mount -t tmpfs -o size="$TMPFS_SIZE" tmpfs "$MOUNT_DIR"

# Add entry to fstab to make it persistent across reboots
echo "Adding tmpfs mount to /etc/fstab for persistence..."
echo "tmpfs $MOUNT_DIR tmpfs defaults,size=$TMPFS_SIZE 0 0" | tee -a /etc/fstab

echo "tmpfs mounted at $MOUNT_DIR with size $TMPFS_SIZE. Configuration added to /etc/fstab."