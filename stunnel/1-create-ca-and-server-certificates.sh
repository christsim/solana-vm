#!/bin/bash -e
HOSTNAME=$1

# Check if the hostname is provided
if [ -z "$HOSTNAME" ]; then
  echo "Error: HOSTNAME not provided. Exiting."
  exit 1
fi

# Check if the hostname directory already exists
if [ -d "${HOSTNAME}_certs" ]; then
  echo "Error: Directory named '${HOSTNAME}_certs' already exists. Exiting."
  exit 1
fi

# Directories to store certificates
CA_DIR="${HOSTNAME}_certs/ca"
SERVER_CERT_DIR="${HOSTNAME}_certs/server"

# Create the directories
mkdir -p "$CA_DIR"
mkdir -p "$SERVER_CERT_DIR"

# File names for CA and server certificates
CA_KEY="${CA_DIR}/${HOSTNAME}_ca.key"
CA_PEM="${CA_DIR}/${HOSTNAME}_ca.pem"
SERVER_KEY="${SERVER_CERT_DIR}/${HOSTNAME}_server.key"
SERVER_CSR="${SERVER_CERT_DIR}/${HOSTNAME}_server.csr"
SERVER_PEM="${SERVER_CERT_DIR}/${HOSTNAME}_server.pem"

# Create the private key for the CA with 4096 bits
openssl genrsa -out "$CA_KEY" 4096

# Create the CA certificate with CN set to the hostname, valid for 20 years
openssl req -new -x509 -days 7300 -key "$CA_KEY" -out "$CA_PEM" -subj "/CN=CA_$HOSTNAME"

### Server

# Create the private key for the server with 4096 bits
openssl genrsa -out "$SERVER_KEY" 4096

# Create a certificate signing request (CSR) for the server with CN set to the hostname
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "/CN=SERVER_$HOSTNAME"

# Sign the server CSR with the CA, valid for 20 years
openssl x509 -req -days 7300 -in "$SERVER_CSR" -CA "$CA_PEM" -CAkey "$CA_KEY" -set_serial 01 -out "$SERVER_PEM"

# Cleanup: Remove the server CSR file
rm "$SERVER_CSR"

# Copy CA's public certificate into the server certificate directory
cp "$CA_PEM" "$SERVER_CERT_DIR"

echo Verifying server pem
openssl verify -CAfile "$CA_PEM" "$SERVER_PEM"
