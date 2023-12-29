#!/bin/bash -e

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. Exiting." 1>&2
   exit 1
fi

# Define variables
HOSTNAME=$1
STUNNEL_CONFIG="/etc/stunnel/stunnel-solana-rpc.conf"
SERVER_CERT_DIR="${HOSTNAME}_certs/server"

# Check for hostname
if [ -z "$HOSTNAME" ]; then
  echo "Error: HOSTNAME not provided. Exiting."
  exit 1
fi

# Install stunnel
echo "Installing stunnel..."
apt-get update
apt-get install -y stunnel

# Copy server keys and certificates
echo "Copying server keys and certificates..."
cp "${SERVER_CERT_DIR}/${HOSTNAME}_server.pem" /etc/stunnel/server.pem
cp "${SERVER_CERT_DIR}/${HOSTNAME}_server.key" /etc/stunnel/server.key
cp "${SERVER_CERT_DIR}/${HOSTNAME}_ca.pem" /etc/stunnel/ca.pem

# Create stunnel configuration
echo "Creating stunnel configuration..."
cat << EOF > "$STUNNEL_CONFIG"
setuid = stunnel4
setgid = stunnel4
pid = /var/run/stunnel4/stunnel.pid

# Security settings
options = NO_SSLv2
options = NO_SSLv3
ciphers = HIGH:!aNULL:!SSLv2:!DH:!kEDH
curve = secp384r1

[solana-http]
client = no
accept = 0.0.0.0:18899
connect = 127.0.0.1:8899
cert = /etc/stunnel/server.pem
key = /etc/stunnel/server.key
CAfile = /etc/stunnel/ca.pem
verify = 2

[solana-ws]
client = no
accept = 0.0.0.0:18900
connect = 127.0.0.1:8900
cert = /etc/stunnel/server.pem
key = /etc/stunnel/server.key
CAfile = /etc/stunnel/ca.pem
verify = 2

[prometheus]
client = no
accept = 0.0.0.0:19100
connect = 127.0.0.1:9100
cert = /etc/stunnel/server.pem
key = /etc/stunnel/server.key
CAfile = /etc/stunnel/ca.pem
verify = 2
EOF

# Restart stunnel service
echo "Restarting stunnel service..."
systemctl restart stunnel4

echo "Stunnel installation and configuration complete."
