#!/bin/bash

# Function to check password complexity
check_password_complexity() {
    local password="$1"
    local min_length=8

    # Check length of the password
    if [ ${#password} -lt $min_length ]; then
        log "Password must be at least $min_length characters long."
        return 1
    fi
    
    # Check for at least one uppercase letter
    if ! [[ "$password" =~ [A-Z] ]]; then
        log "Password must contain at least one uppercase letter."
        return 1
    fi
    
    # Check for at least one lowercase letter
    if ! [[ "$password" =~ [a-z] ]]; then
        log "Password must contain at least one lowercase letter."
        return 1
    fi
    
    # Check for at least one number
    if ! [[ "$password" =~ [0-9] ]]; then
        log "Password must contain at least one number."
        return 1
    fi

    # Check for at least one special character
    if ! [[ "$password" =~ [[:punct:]] ]]; then
        log "Password must contain at least one special character."
        return 1
    fi

    return 0
}

# The script will be called with the new password as an argument
new_password="$1"

# Call the function to check password complexity
check_password_complexity "$new_password"
if [[ $? -ne 0 ]]; then
    exit 1  # Reject password change if it doesn't meet complexity
fi

# Return success if password is valid
exit 0