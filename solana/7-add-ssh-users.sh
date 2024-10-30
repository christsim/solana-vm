#!/bin/bash

# Each entry in the SSH_KEYS array must contain exactly 3 space-separated values:
#
# 1. The SSH key type (e.g., "ssh-rsa", "ssh-ed25519", etc.)
# 2. The base64-encoded public key string (e.g., "AAAAB3NzaC1yc2EAAAA...")
# 3. The user's name (e.g., "bob") - this will be used to created the user's home directory

SSH_KEYS=(
    #   "ssh-rsa AAAAB3NzaC1yc2... bob"
    #   "ssh-rsa AAAAB3NzaC1yc3... alice"
)

# Check ssh key format
for ssh_key in "${SSH_KEYS[@]}"; do
    data=(${ssh_key})
    if [[ ${#data[@]} -ne 3 ]]; then
        echo "Invalid SSH_KEY: '${ssh_key}' does not contain exactly 3 values."
        exit 1
    fi
done

# Check that the array has more than 0 entries
if [[ ${#SSH_KEYS[@]} -eq 0 ]]; then
    echo "[-] SSH_KEYS cannot be empty. Please update this script before rerunning:"
    sed -n '2,14p' ${0}
    exit 1
fi

function add_users() {
    # create group 'solana-users' if not exists
    if ! getent group "solana-users" >/dev/null; then
        groupadd "solana-users"
    fi

    for ssh_key in "${SSH_KEYS[@]}"; do
        user=$(echo "${ssh_key}" | awk '{print $NF}')
        key=$(echo "${ssh_key}" | awk '{$NF=""; print $0}')

        # create user if not exists
        if ! getent passwd "${user}" >/dev/null; then
            useradd -m -d "/home/${user}" -s /bin/bash "${user}"
        fi

        # add user to group if not there
        if [ -z "$(getent group 'solana-users' | grep ${user})" ]; then
            usermod -aG solana-users ${user}
        fi

        # create ssh dir
        if [ ! -d "/home/${user}/.ssh" ]; then
            mkdir "/home/${user}/.ssh"
            chown ${user}:${user} "/home/${user}/.ssh"
            chmod 700 "/home/${user}/.ssh"
        fi

        # add ssh key and set permissions if not present
        if [ ! -f "/home/${user}/.ssh/authorized_keys" ] || ! grep -qF -- "${key}" "/home/${user}/.ssh/authorized_keys"; then
            echo "${key}" >>/home/${user}/.ssh/authorized_keys
            chown ${user}:${user} "/home/${user}/.ssh/authorized_keys"
            chmod 600 "/home/${user}/.ssh/authorized_keys"
        fi

    done

    echo "Done! You'll need to manually add the following line to /etc/sudoers (adapt as necessary)"
    echo "%solana-users  ALL=(ALL) NOPASSWD: ALL"
}