#!/bin/bash
# Lab: Automating Identity and Access Management in Linux with Bash

users_file="users.txt"
log_file="iam_setup.log"
first_line_skipped=false
temporary_password="ChangeMe123"

# Function to log messages with timestamps
log() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message" | tee -a "$log_file"
}

# Read the file line by line
while IFS=',' read -r username fullname group; do
    # Skip the header row
    if [ "$first_line_skipped" = false ]; then
        first_line_skipped=true
        continue
    fi

    # Create group if it doesn't exist
    if ! getent group "$group" > /dev/null; then
        log "Creating group: $group"
        sudo groupadd "$group"
    else
        log "Group $group already exists."
    fi
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        log "User $username already exists. Skipping..."
        continue
    fi
    
    # Create user with home directory, group, and full name
    useradd -m -g "$group" -c "$fullname" "$username"
    log "User '$username' created and added to group '$group'."
    
    # Set a temporary password
    echo "$username:$temporary_password" | chpasswd
    log "Temporary password set for user '$username'."

    # Force user to change password on first login
    chage -d 0 "$username"
    log "Password reset required at next login for '$username'."
    
    # set user's home directory to be only accessible by that user
    chmod 700 /home/"$username"
    log "Permissions set to 700 for /home/$username"


done < "$users_file"

