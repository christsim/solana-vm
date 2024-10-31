# solana_vm

Runs solana on a vm/bare metal
Only tested on Ubuntu 22.04

// mount physical disks to /mnt/disk*
e.g.
/mnt/disk1 --> /dev/md0
/mnt/disk2 --> /dev/nvme1

// then mount bind to solana folders
/mnt/disk1/ledger     --> /opt/solana/ledger
/mnt/disk2/snapshots  --> /opt/solana/snapshots
/mnt/disk2/accounts   --> /opt/solana/accounts


...