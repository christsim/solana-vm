#!/bin/bash

echo running as $USER

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install tuned
echo "Installing tuned..."
apt update
apt install -y tuned

# Start and enable tuned
echo "Starting and enabling tuned..."
systemctl start tuned
systemctl enable tuned

# Create the tuned profile directory
echo "Creating tuned profile for Solana validator..."
mkdir -p /etc/tuned/solana-validator-performance

# Create the tuned.conf file with Solana-optimized settings
cat <<EOL > /etc/tuned/solana-validator-performance/tuned.conf
# Tuned profile optimized for Solana validator with throughput-performance as a base

[main]
summary=Optimized performance profile for Solana validator
include=throughput-performance

[cpu]
# Forces CPU to operate at maximum frequency and disables power-saving latency
governor=performance                 # Keeps CPU at maximum frequency
energy_perf_bias=performance
force_latency=1                      # Disables power-saving transitions

# Minimal preemption granularity and wake-up granularity for CPU-bound tasks
min_granularity_ns=10000000          # Minimum granularity for CPU tasks
wakeup_granularity_ns=15000000       # Wake-up granularity

[disk]
# Maintains default throughput-performance disk settings

[vm]
# Virtual memory optimizations for high I/O and Solana-specific tuning
swappiness=30                        # Moderate swappiness for balance between disk and memory
dirty_ratio=40                       # Higher threshold for dirty pages before flush
dirty_background_ratio=10            # Background dirty page flushing starts
dirty_expire_centisecs=36000         # Time before dirty pages are eligible for writeback (in centisecs)
dirty_writeback_centisecs=3000       # Dirty pages writeback frequency (in centisecs)
dirtytime_expire_seconds=43200       # Expiration time for dirty pages (in seconds)
max_map_count=1000000                # Supports high memory mappings for Solana's usage
stat_interval=10                     # Reduces VM stat collection frequency for lower latency

[sysctl]
# Disable the watchdog timer and timer migration
kernel.nmi_watchdog=0                # Disables NMI watchdog for reduced latency
kernel.timer_migration=0             # Disables timer migration for lower latency
kernel.hung_task_timeout_secs=600    # Increases hung task timeout threshold for long-running processes

# PID limit based on CPU count; suggested formula is 1024 * number of CPU cores
kernel.pid_max=65536                 # Max PID based on typical CPU count

# Network performance optimizations
net.ipv4.tcp_fastopen=3              # Enables TCP Fast Open for faster connections
net.core.rmem_max=134217728          # Max receive buffer
net.core.rmem_default=134217728      # Default receive buffer
net.core.wmem_max=134217728          # Max send buffer
net.core.wmem_default=134217728      # Default send buffer
EOL

# Activate the tuned profile
echo "Activating the Solana validator tuned profile..."
tuned-adm profile solana-validator-performance

echo "Tuned profile 'solana-validator-performance' has been successfully created and activated!"

tuned-adm active