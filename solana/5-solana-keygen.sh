#!/bin/bash -xe

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Create Keypair file
solana-keygen new --outfile /opt/solana/validator-keypair.json
chmod 600 /opt/solana/validator-keypair.json
chown solana:solana /opt/solana/validator-keypair.json