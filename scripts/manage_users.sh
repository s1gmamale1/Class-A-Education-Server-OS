#!/bin/bash
#
# manage_users.sh — Class A Education users & group management
#   - Creates the classa_staff group and 3 role accounts (bash shell + home dir)
#   - Grants sudo to the platform administrator
#   - Drops a read-only readme.txt into each home
#   - Adds 3 aliases + a restrictive umask (0277) to each .bashrc (idempotent)
#
# Safe to re-run. Use `--reset` to delete and recreate the users from scratch.
#
set -euo pipefail

GROUP_NAME="classa_staff"
USERS=("platform_admin" "content_editor" "support_user")
SUDO_USER_NAME="platform_admin"
MARKER="# >>> Class A Education config >>>"

# ----------------------------------------------------------------- --reset ---
if [[ "${1:-}" == "--reset" ]]; then
    for u in "${USERS[@]}"; do
        if id "$u" >/dev/null 2>&1; then
            echo "Removing existing user $u ..."
            sudo pkill -u "$u" 2>/dev/null || true
            sudo userdel -r "$u" 2>/dev/null || true
        fi
    done
fi

echo "Creating group: $GROUP_NAME"
sudo groupadd -f "$GROUP_NAME"

for user in "${USERS[@]}"; do
    if id "$user" >/dev/null 2>&1; then
        echo "User $user already exists — ensuring configuration."
    else
        echo "Creating user: $user"
        sudo useradd -m -s /bin/bash "$user"
    fi

    echo "  adding $user to $GROUP_NAME"
    sudo usermod -aG "$GROUP_NAME" "$user"

    # Custom file in the home directory, owner read-only.
    echo "Welcome to the Class A Education server. Your files are private and read-only by default." \
        | sudo tee "/home/$user/readme.txt" >/dev/null
    sudo chown "$user:$user" "/home/$user/readme.txt"
    sudo chmod 400 "/home/$user/readme.txt"

    # Aliases + umask — appended only once thanks to the marker (no duplicates on re-run).
    if ! sudo grep -qF "$MARKER" "/home/$user/.bashrc" 2>/dev/null; then
        sudo tee -a "/home/$user/.bashrc" >/dev/null <<EOF

$MARKER
alias ll='ls -la'
alias logs='cd /var/classa/app/logs'
alias app='cd /var/classa/app'
# New files default to owner read-only (0400); nothing for group/others.
umask 0277
# <<< Class A Education config <<<
EOF
        sudo chown "$user:$user" "/home/$user/.bashrc"
        echo "  configured aliases + umask for $user"
    else
        echo "  $user already configured (skipping .bashrc append)"
    fi

    # Keep each home private.
    sudo chmod 750 "/home/$user"
done

echo "Granting sudo permissions to $SUDO_USER_NAME ..."
sudo usermod -aG sudo "$SUDO_USER_NAME"

echo "User and group setup completed successfully."
