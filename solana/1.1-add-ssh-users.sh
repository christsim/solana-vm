#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <ssh_keys_file>"
    echo "\nFormat of <ssh_keys_file>:"
    echo "<key_type> <base64_encoded_key> <username>"
    echo "Example:"
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... user1"
    exit 1
fi

# load the file
mapfile -t SSH_KEYS < "$1"

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

for ssh_key in "${SSH_KEYS[@]}"; do
    data=(${ssh_key})
    if [[ ${#data[@]} -ne 3 ]]; then
        log "Invalid SSH_KEY: '${ssh_key}' does not contain exactly 3 values."
        exit 1
    fi
done

if [[ ${#SSH_KEYS[@]} -eq 0 ]]; then
    log "[-] SSH_KEYS cannot be empty. Please update this script before rerunning:"
    sed -n '2,14p' "$0"
    exit 1
fi

function add_users() {
    if ! getent group "blockchain-users" >/dev/null; then
        groupadd "blockchain-users"
        log "Created group 'blockchain-users'."
    else
        log "Group 'blockchain-users' already exists."
    fi

    for ssh_key in "${SSH_KEYS[@]}"; do
        user=$(echo "$ssh_key" | awk '{print $NF}')
        key=$(echo "$ssh_key" | cut -d' ' -f1-2)

        if getent passwd "$user" >/dev/null; then
            log "User '$user' already exists. Skipping key addition."
            continue
        fi

        useradd -m -d "/home/$user" -s /bin/bash "$user"
        log "Created user '$user'."

        usermod -aG blockchain-users "$user"

        mkdir -p "/home/$user/.ssh"
        chmod 700 "/home/$user/.ssh"
        chown "$user:$user" "/home/$user/.ssh"

        echo "$key" >> "/home/$user/.ssh/authorized_keys"
        chmod 600 "/home/$user/.ssh/authorized_keys"
        chown "$user:$user" "/home/$user/.ssh/authorized_keys"
        log "Added SSH key for user '$user'."
    done

    if ! grep -q "^%blockchain-users ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
        echo "%blockchain-users ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        log "Added '%blockchain-users' to /etc/sudoers."
    else
        log "'%blockchain-users' is already in /etc/sudoers."
    fi

    log "User setup completed."
}

add_users
