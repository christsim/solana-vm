#!/bin/bash -xe

echo running as $USER

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo running as sudo: $SUDO_USER

useradd -r -s /bin/false solana
groupadd "solana-users"

usermod -aG solana solana
usermod -aG solana $SUDO_USER
usermod -aG systemd-journal $SUDO_USER
usermod -aG solana-users solana
