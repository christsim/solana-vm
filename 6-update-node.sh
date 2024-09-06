#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Please enter the Solana version number (e.g., v1.16.19):"
    echo "usage $0 [version]"
    exit 1
fi

# Start the Service
echo "stopping the solana service"
systemctl stop agave-validator.service

#Build

./3-build.sh $VERSION

# Start the Service
echo "starting the solana service"
systemctl start agave-validator.service
