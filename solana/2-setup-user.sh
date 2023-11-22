#!/bin/bash -xe

echo running as $USER

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo running as sudo: $SUDO_USER

useradd -r -s /bin/false solana

usermod -aG solana solana
usermod -aG solana $SUDO_USER
usermod -aG systemd-journal $SUDO_USER

# refresh the groups
newgrp solana
newgrp systemd-journal

# Create Solana data directory
mkdir -pv /opt/solana
# Create directory for ledger
mkdir -p /opt/solana/ledger

chown -R solana:solana /opt/solana
chmod -R 775 /opt/solana

