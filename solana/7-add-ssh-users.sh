#!/bin/bash

# Each entry in the SSH_KEYS array must contain exactly 3 space-separated values:
#
# 1. The SSH key type (e.g., "ssh-rsa", "ssh-ed25519", etc.)
# 2. The base64-encoded public key string (e.g., "AAAAB3NzaC1yc2EAAAA...")
# 3. The user's name (e.g., "bob") - this will be used to create the user's home directory

SSH_KEYS=(
    #   "ssh-rsa AAAAB3NzaC1yc2... bob"
    #   "ssh-rsa AAAAB3NzaC1yc3... alice"
)

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Check ssh key format
for ssh_key in "${SSH_KEYS[@]}"; do
    data=(${ssh_key})
    if [[ ${#data[@]} -ne 3 ]]; then
        log "Invalid SSH_KEY: '${ssh_key}' does not contain exactly 3 values."
        exit 1
    fi
done

# Check that the array has more than 0 entries
if [[ ${#SSH_KEYS[@]} -eq 0 ]]; then
    log "[-] SSH_KEYS cannot be empty. Please update this script before rerunning:"
    sed -n '2,14p' "$0"
    exit 1
fi

function add_users() {
    # Create group 'solana-users' if it does not exist
    if ! getent group "solana-users" >/dev/null; then
        groupadd "solana-users"
        log "Created group 'solana-users'."
    else
        log "Group 'solana-users' already exists."
    fi

    for ssh_key in "${SSH_KEYS[@]}"; do
        user=$(echo "$ssh_key" | awk '{print $NF}')
        key=$(echo "$ssh_key" | awk '{$NF=""; print $0}')

        # Create user if it does not exist
        if ! getent passwd "$user" >/dev/null; then
            useradd -m -d "/home/$user" -s /bin/bash "$user"
            log "Created user '$user'."
        else
            log "User '$user' already exists."
        fi

        # Add user to group if not already a member
        if ! id -nG "$user" | grep -qw "solana-users"; then
            usermod -aG solana-users "$user"
            log "Added user '$user' to group 'solana-users'."
        fi

        # Create .ssh directory if it does not exist
        if [ ! -d "/home/$user/.ssh" ]; then
            mkdir "/home/$user/.ssh"
            chown "$user:$user" "/home/$user/.ssh"
            chmod 700 "/home/$user/.ssh"
            log "Created .ssh directory for user '$user'."
        fi

        # Add SSH key to authorized_keys if not already present
        if [ ! -f "/home/$user/.ssh/authorized_keys" ] || ! grep -qF -- "$key" "/home/$user/.ssh/authorized_keys"; then
            echo "$key" >> "/home/$user/.ssh/authorized_keys"
            chown "$user:$user" "/home/$user/.ssh/authorized_keys"
            chmod 600 "/home/$user/.ssh/authorized_keys"
            log "Added SSH key for user '$user'."
        else
            log "SSH key for user '$user' is already present."
        fi
    done

    log "User setup completed. Add the following line to /etc/sudoers if needed:"
    echo "%solana-users  ALL=(ALL) NOPASSWD: ALL" | tee -a "$LOG_FILE"
}

# Run the add_users function
add_users