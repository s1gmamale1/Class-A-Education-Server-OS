#!/bin/bash

GROUP_NAME="classa_stuff"
USERS=("platform_admin" "content_editor" "support_user")

echo "Creating group: $GROUP_NAME"
sudo groupadd -f "$GROUP_NAME"

for user in "${USERS[@]}"; do
	if id "$user" >/dev/null 2>&1; then
		echo "User $user already exists. Skipping creation."
	else
		echo "Creating user: $user"
		sudo useradd -m -s /bin/bash "$user"
	fi

	echo "Adding $user to $GROUP_NAME"
	sudo usermod -aG "$GROUP_NAME" "$user"

	echo "Creating readme.txt for $user"
	echo "Welcome to Class A Education server. Your files are are private and read-only by default." | sudo tee "/home/$user/readme.txt" > /dev/null
	sudo chown "$user:$user" "/home/$user/readme.txt"
	sudo chmod 400 "/home/$user/readme.txt"

	echo "Adding aliases and umask to /home/$user/.bashrc"
	sudo bash -c "cat >> /home/$user/.bashrc" << 'EOF'

# Class A Education custom aliases
alias ll='ls -la'
alias logs='cd /var/classa/app/logs'
alias app='cd /var/classa/app'


# Default file permission policy
umask 0277
EOF

	sudo chown "$user:$user" "/home/$user/.bashrc"

	echo "Configure $user"
done

echo "Giving sudo permissions to platform_admin..."
sudo usermod -aG sudo platform_admin

echo "User and Group set up successfully completed."
