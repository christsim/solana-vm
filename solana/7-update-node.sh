#!/bin/bash -xe

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Please enter the Solana version number (e.g., v1.16.19):"
    echo "usage $0 [version]"
    exit 1
fi

# Start the Service
echo "stopping the solana service"
systemctl stop solana-validator.service

#Build

./4-build.sh $VERSION

# Start the Service
echo "starting the solana service"
systemctl start solana-validator.service
