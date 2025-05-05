# 🔐 IAM Bash Automation Script

This repository contains a Bash script (`iam_setup.sh`) that automates user and group creation, applies secure password policies, sets proper home directory permissions, and optionally sends email notifications — all based on a provided CSV input file.

---

## 🚀 Features

- ✅ Create Linux groups if they don’t exist
- ✅ Create user accounts with full name, group, home directory
- ✅ Set default password and enforce change on first login
- ✅ Enforce home directory permissions (`chmod 700`)
- ✅ Log all actions to `iam_setup.log`
- ✅ Accept CSV input file as command-line argument
- ✅ Validate password complexity
- ✅ Send email notifications (optional)

---

## 📁 Sample CSV File (`users.txt`)

```csv
username,fullname,group
jdoe,John Doe,engineering
asmith,Alice Smith,engineering
mjones,Mike Jones,design

```
---

## 🛠️ Prerequisites
- A Linux machine (physical, VM, or WSL)
- Basic knowledge of Bash scripting
- Familiarity with `useradd`, `usermod`, `passwd`, and `chage`

---

## Scenario
You are a system administrator for a mid-sized company. A new department requires multiple user accounts to be created, each with a specific home directory, group membership, and password policy. Your task is to automate this process to save time and reduce human error.

---

## ⚙️ Usage
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
./iam_setup.sh 

```
Make sure the script and users.txt are in the same directory.

---

## 📝 Logging

*All actions are logged to:*
```
iam_setup.log

```
This includes group creation, user creation, password assignment, and any skipped entries.

