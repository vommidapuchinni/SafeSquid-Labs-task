#!/bin/bash

# Define the log file
LOG_FILE="./logs/audit.log"

# Ensure the log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# User and Group Audits
log "Starting user and group audits..."
log "Listing all users and groups:"
cut -d: -f1 /etc/passwd | tee -a "$LOG_FILE"
log "Checking for users with UID 0:"
awk -F: '$3 == 0 {print $1}' /etc/passwd | tee -a "$LOG_FILE"
log "Checking for users without passwords or weak passwords:"
awk -F: '($2 == "" || length($2) < 8) {print $1 " has a weak password"}' /etc/shadow | tee -a "$LOG_FILE"

# File and Directory Permissions
log "Starting file and directory permission checks..."
log "Scanning for world-writable files and directories:"
find / -type f -perm -o+w -exec ls -ld {} \; 2>/dev/null | tee -a "$LOG_FILE"
log "Checking for presence of .ssh directories:"
find /home/*/.ssh -type d -exec ls -ld {} \; | tee -a "$LOG_FILE"
log "Checking for files with SUID/SGID bits set:"
find / -perm /6000 -exec ls -ld {} \; 2>/dev/null | tee -a "$LOG_FILE"

# Service Audits
log "Starting service audits..."
log "Listing all running services:"
systemctl list-units --type=service --state=running | tee -a "$LOG_FILE"
log "Checking for unauthorized services:"
# Add specific checks for unauthorized services

# Firewall and Network Security
log "Verifying firewall status and configuration..."
firewall-cmd --state | tee -a "$LOG_FILE"
firewall-cmd --list-all | tee -a "$LOG_FILE"
iptables -L -v -n | tee -a "$LOG_FILE"
log "Checking for open ports and associated services:"
ss -tuln | tee -a "$LOG_FILE"

# IP and Network Configuration Checks
log "Checking IP and network configurations..."
log "Identifying public and private IPs:"
ip -o -f inet addr show | awk '/scope global/ {print $2, $4}' | tee -a "$LOG_FILE"
# Add logic to differentiate public/private IPs

# Security Updates and Patching
log "Checking for available security updates..."
yum check-update --security | tee -a "$LOG_FILE"

# Log Monitoring
log "Checking logs for suspicious activities..."
if command -v journalctl >/dev/null; then
    journalctl -u sshd | grep "Failed password" | tee -a "$LOG_FILE"
else
    log "No log monitoring tools found."
fi

log "Security audit completed."

