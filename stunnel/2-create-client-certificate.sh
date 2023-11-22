#!/bin/bash -e
HOSTNAME=$1
CLIENTID=$2

# Verify if the hostname directory exists
if [ ! -d "${HOSTNAME}_certs" ]; then
  echo "Error: Directory for hostname '${HOSTNAME}_certs' does not exist. Exiting."
  exit 1
fi

# Check for the existence of the CA certificate
if [ ! -f "${HOSTNAME}_certs/ca/${HOSTNAME}_ca.pem" ]; then
  echo "Error: CA certificate '${HOSTNAME}_ca.pem' does not exist in the expected location. Exiting."
  exit 1
fi

if [ -z "$CLIENTID" ]; then
  echo "Error: CLIENTID not provided. Exiting."
  exit 1
fi

# Directory to store client certificates
CLIENT_CERT_DIR="${HOSTNAME}_certs/client_${CLIENTID}"

# Check if the client directory already exists
if [ -d "$CLIENT_CERT_DIR" ]; then
  echo "Error: Client certificate directory '$CLIENT_CERT_DIR' already exists. Exiting."
  exit 1
fi

mkdir -p "$CLIENT_CERT_DIR"

# Copy CA's public certificate into the client folder
cp "${HOSTNAME}_certs/ca/${HOSTNAME}_ca.pem" "${CLIENT_CERT_DIR}/ca.pem"

# Create the private key for the client with 4096 bits
openssl genrsa -out "${CLIENT_CERT_DIR}/client_${CLIENTID}.key" 4096

# Create a certificate signing request (CSR) for the client without prompts
openssl req -new -key "${CLIENT_CERT_DIR}/client_${CLIENTID}.key" -out "${CLIENT_CERT_DIR}/client_${CLIENTID}.csr" -subj "/CN=${CLIENTID}"

# Sign the client CSR with the CA, valid for 7300 days
openssl x509 -req -days 7300 -in "${CLIENT_CERT_DIR}/client_${CLIENTID}.csr" -CA "${HOSTNAME}_certs/ca/${HOSTNAME}_ca.pem" -CAkey "${HOSTNAME}_certs/ca/${HOSTNAME}_ca.key" -set_serial "${CLIENTID}" -out "${CLIENT_CERT_DIR}/client_${CLIENTID}.pem"

# Cleanup: Remove the client CSR file
rm "${CLIENT_CERT_DIR}/client_${CLIENTID}.csr"


echo Verifying client pem
openssl verify -CAfile "${HOSTNAME}_certs/ca/${HOSTNAME}_ca.pem" "${CLIENT_CERT_DIR}/client_${CLIENTID}.pem"