#!/bin/bash -xe

#Optional,  setup swap file

# Check if the path and size arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <swapfile_path> <swapfile_size>"
  echo "Example: $0 /swapfile 250G"
  exit 1
fi

# Set swapfile path and size from arguments
SWAPFILE_PATH="$1"
SWAPFILE_SIZE="$2"

# Create swap file
echo "Creating swap file at $SWAPFILE_PATH with size $SWAPFILE_SIZE..."
sudo fallocate -l "$SWAPFILE_SIZE" "$SWAPFILE_PATH"
sudo chmod 0600 "$SWAPFILE_PATH"
sudo mkswap "$SWAPFILE_PATH"

# Start swap
echo "Activating swap..."
sudo swapon "$SWAPFILE_PATH"

# Save swap mount in fstab
echo "Saving swap configuration in /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.bak
echo "$SWAPFILE_PATH none swap sw 0 0" | sudo tee -a /etc/fstab

echo "Swap setup complete. Swap file: $SWAPFILE_PATH, Size: $SWAPFILE_SIZE"