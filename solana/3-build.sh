#!/bin/bash -xe

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Please enter the Solana version number (e.g., v1.16.19):"
    echo "usage $0 [version]"
    exit 1
fi

echo attempting to build Version $VERSION

# Update and upgrade the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install necessary dependencies
sudo apt-get install -y git build-essential pkg-config libssl-dev libudev-dev libclang-dev llvm byobu

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig/libudev.pc
export LIBCLANG_PATH=/usr/lib/llvm-14/lib/libclang.so

if [ ! -f "/usr/lib/x86_64-linux-gnu/pkgconfig/libudev.pc" ]; then
    echo "File does not exist: /usr/lib/x86_64-linux-gnu/pkgconfig/libudev.pc"
    exit 1  # Exit with a non-zero status to indicate an error
fi

if [ ! -f "/usr/lib/llvm-14/lib/libclang.so" ]; then
    echo "File does not exist: /usr/lib/llvm-14/lib/libclang.so"
    exit 1  # Exit with a non-zero status to indicate an error
fi


# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --profile minimal
source $HOME/.cargo/env

# Clone the Solana repository and build from source
git clone https://github.com/solana-labs/solana.git /opt/solana/build/$VERSION
cd /opt/solana/build/$VERSION
git fetch
git checkout $VERSION

# Build Solana
cargo build --release

# remove previous versions
sudo rm -f "/usr/local/bin/solana-validator"
sudo rm -f "/usr/local/bin/solana"
sudo rm -f "/usr/local/bin/solana-keygen"

# Move Binaries to /usr/local
sudo ln -s /opt/solana/build/$VERSION/target/release/solana-validator /usr/local/bin/solana-validator
sudo ln -s /opt/solana/build/$VERSION/target/release/solana /usr/local/bin/solana
sudo ln -s /opt/solana/build/$VERSION/target/release/solana-keygen /usr/local/bin/solana-keygen
