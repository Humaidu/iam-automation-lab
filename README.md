# 🔐 IAM Bash Automation Script

This repository contains a Bash script (`iam_setup.sh`) that automates user and group creation, applies secure password policies, sets proper home directory permissions, and optionally sends email notifications — all based on a provided CSV input file.

---

## Features

- ✅ Create Linux groups if they don’t exist
- ✅ Create user accounts with full name, group, home directory
- ✅ Set default password and enforce change on first login
- ✅ Enforce home directory permissions (`chmod 700`)
- ✅ Log all actions to `iam_setup.log`
- ✅ Accept CSV input file as command-line argument
- ✅ Validate password complexity
- ✅ Send email notifications (optional)

---

## Sample CSV File (`users.txt`)

```csv
username,fullname,group
jdoe,John Doe,engineering
asmith,Alice Smith,engineering
mjones,Mike Jones,design

```

---
## Prerequisites
- A Linux machine (physical, VM, or WSL)
- Basic knowledge of Bash scripting
- Familiarity with `useradd`, `usermod`, `passwd`, and `chage`
- Run the script with sudo
- For Gmail notifications, use an App Password

---

## Scenario
You are a system administrator for a mid-sized company. A new department requires multiple user accounts to be created, each with a specific home directory, group membership, and password policy. Your task is to automate this process to save time and reduce human error.

---

## Usage
*1. Clone the Repository*
```
git clone https://github.com/yourusername/iam-automation.git
cd iam-automation

```

*2. Make Script Executable*
```
chmod +x iam_setup.sh

```
*3. Run the Script*
```
sudo ./iam_setup.sh users.txt

```
*NB:* The script must be run with sudo
Make sure the script and users.txt are in the same directory.

---

## Logging

*All actions are logged to:*
```
iam_setup.log

```
This includes group creation, user creation, password assignment, and any skipped entries.

---

## Optional Email Notifications

**email notification** system sends an email to each user after account creation. Emails are sent using a configured SMTP server (e.g., Gmail), ensuring delivery across platforms and environments.

### How The Email Notifications Work
Once a user is successfully created via the IAM automation script, an email is sent to notify them of their new account and temporary login details.

### 🔁 Email Logic
- If the script is configured with a valid SMTP setup (e.g., Gmail + Postfix), it sends emails using the `mail` command.
- The email contains:
  - A greeting
  - Username and assigned group
  - A prompt to change their temporary password on first login

### Configuration
#### 1. Configure Postfix for Gmail SMTP

Ensure Postfix is installed and configured to use Gmail's SMTP.

```bash
sudo apt update
sudo apt install postfix mailutils libsasl2-2 ca-certificates libsasl2-modules -y
```

Edit /etc/postfix/main.cf:
```
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt

```

Create /etc/postfix/sasl_passwd:
```
[smtp.gmail.com]:587 your.email@gmail.com:your_app_password

```
Then run:
```
sudo postmap /etc/postfix/sasl_passwd
sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo systemctl restart postfix

```

*Note on Gmail*
- You must use an App Password — regular Gmail password will not work.
- App Passwords are created in your Google Account > Security > App passwords.

## Usage in Script
The script sends email like this:

```
echo "Hello $fullname,

Your user account ($username) has been created and added to group '$group'.

Temporary password: ChangeMe123
Please change it on first login."
| mail -s "Account created" "$default_email"

```
*NB:* default_email can be customized in the script. Currently set to my email humaiduali@gmail.com for testing purposes 

---

## Cross-Platform Considerations
While the mail command works well on Unix-like systems with Postfix, for full cross-platform support (e.g., Windows, Docker, CI/CD):

- Consider using a Python-based SMTP solution (see below).
- Ensure internet access and allow port 587 outbound for Gmail.

---

## Python-based Fallback
Create a *send_mail.py* file using *smtplib* and email modules to send email from anywhere.

```
# send_mail.py
# Usage: python3 send_mail.py "user@example.com" "Subject" "Message"

```

---

## Password Complexity Enforcement

This project uses **PAM (Pluggable Authentication Modules)** to enforce secure password creation policies. Specifically, it leverages the `pam_pwquality.so` module, which checks passwords against defined complexity rules.

### Enforced Complexity Rules

These rules are defined in `/etc/pam.d/common-password`:

```bash
password requisite pam_pwquality.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1

```
This means:

- Minimum password length: 8 characters
- At least one uppercase letter (ucredit=-1)
- At least one lowercase letter (lcredit=-1)
- At least one digit (dcredit=-1)
- At least one special character (ocredit=-1)
- Up to 3 retries are allowed before the password change fails

### Temporary Password Requirements

When creating users, a temporary password is set and users are required to change it on their first login. Ensure this password meets the complexity policy above.

*Example (Valid) Temporary Password:*
```
ChangeMe@123

```
### How It Works

- User accounts are created with a default password (ChangeMe@123).
- The PAM system enforces complexity at the time of password setting or user login.
- If the password doesn't meet the policy, the script will fail to set it.
- Users are forced to change their password on first login with *chage -d 0*.

### Testing Password Complexity
To test the policy manually:
```
sudo su - <username>

```
Try entering a weak password to confirm rejection.

---
## Files

- iam_setup.sh - Main automation script
- send_mail.py - Python fallback for sending emails
- .env - Contains Gmail credentials (when using SMTP fallback)
- users.txt - CSV input file containing username,fullname,group




