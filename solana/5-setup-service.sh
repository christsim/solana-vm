#!/bin/bash -xe

echo running as $USER

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo running as sudo: $SUDO_USER

## Create a script in /usr/local/bin called start-solana.sh
tee /usr/local/bin/start-solana.sh > /dev/null <<EOF
#!/bin/bash

/usr/local/bin/agave-validator \
    --enable-extended-tx-metadata-storage \
    --no-voting \
    --no-port-check \
    --no-poh-speed-test \
    --log - \
    --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
    --identity /opt/solana/validator-keypair.json \
    --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
    --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
    --known-validator CW9C7HBwAMgqNdXkNgFg9Ujr3edR2Ab9ymEuQnVacd1A \
    --known-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
    --known-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
    --known-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
    --known-validator LA1NEzryoih6CQW3gwQqJQffK2mKgnXcjSQZSRpM3wc \
    --known-validator 722RdWmHC5TGXBjTejzNjbc8xEiduVDLqZvoUGz6Xzbp \
    --known-validator Ninja1spj6n9t5hVYgF3PdnYz2PLnkt7rvaw3firmjs \
    --known-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
    --wal-recovery-mode skip_any_corrupted_record \
    --only-known-rpc \
    --ledger /opt/solana/ledger \
    --limit-ledger-size 520000000 \
    --rpc-bind-address 127.0.0.1 \
    --rpc-port 8899 \
    --private-rpc \
    --enable-rpc-transaction-history \
    --full-rpc-api \
    --accounts /opt/solana-accounts \
    --minimal-snapshot-download-speed 250000000
EOF

# Create a Systemd Service File
tee /etc/systemd/system/solana-validator.service > /dev/null <<EOF
[Unit]
Description=Solana Validator
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/start-solana.sh
User=solana
Restart=on-failure
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
EOF

# Make the script executable
chmod +x /usr/local/bin/start-solana.sh

# Reload the Systemd Manager Configuration
systemctl daemon-reload

# Enable the Service
systemctl enable solana-validator.service

echo solana service created
echo ..
echo run ./start-service.sh to start.
