#!/bin/bash
# Lab: Automating Identity and Access Management in Linux with Bash


log_file="iam_setup.log"
temporary_password="ChangeMe@123"

# Function to log messages with timestamps
log() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message" | tee -a "$log_file"
}

# Check if the script is running as root (sudo)
if [ "$(id -u)" -ne 0 ]; then
    log "This script must be run with sudo. Exiting."
    exit 1
fi

# Check if CSV file path was provided
if [[ $# -ne 1 ]]; then
    log "Usage: $0 users.txt"
    exit 1
fi

users_file="$1"

# Validate file exists
if [[ ! -f "$users_file" ]]; then
    log "Error: File '$users_file' not found."
    exit 1
fi

# Function to Send email notification
send_notification() {
    local fullname="$1"
    local username="$2"
    local temporary_password="$3"
    local email="humaiduali@gmail.com"

    email_body=$(cat <<EOF
Hello $fullname,

Your account '$username' has been created.
Temporary password: $temporary_password
Please change it upon first login.
EOF
)
   
    if command -v mail &> /dev/null; then
        echo "$email_body" | mail -s "Account Created" "$email"
        log "Notification sent to $email"
    else
        log "mail command not available. Using send_mail.py."
        source env/bin/activate
        export $(grep -v '^#' .env | xargs)
        python3 send_mail.py "$email" "Account Created" "$email_body"
        log "Notification sent to $email"

    fi
}


# Read the file line by line
while IFS=',' read -r username fullname group; do
    # Skip the header row and empty lines
    [[ -z "$username" || "$username" == "username" ]] && continue

    log ""
    log "Processing user: $username"

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
    log ""
    
    # Set a temporary password
    echo "$username:$temporary_password" | chpasswd
    if [ $? -eq 0 ]; then
        log "Temporary password set for user '$username'."
    else
        log "Failed to set password for user '$username'."
    fi

    # Force user to change password on first login
    chage -d 0 "$username"
    log "Password reset required at next login for '$username'."
    
    # set user's home directory to be only accessible by that user
    chmod 700 /home/"$username"
    log "Permissions set to 700 for /home/$username"

    # Send email notification
    send_notification "$fullname" "$username" "$temporary_password"
    log ""

done < "$users_file"

log ""
log "IAM setup completed."

