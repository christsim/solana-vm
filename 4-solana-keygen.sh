#!/bin/bash -xe

# Create Keypair file
solana-keygen new --outfile /opt/solana/validator-keypair.json
chmod 600 /opt/solana/validator-keypair.json
chown solana:solana /opt/solana/validator-keypair.json