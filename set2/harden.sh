#!/bin/bash

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

LOG_FILE="./logs/harden.log"
mkdir -p "$(dirname "$LOG_FILE")"

log "Starting server hardening..."

# SSH Configuration
log "Enforcing SSH key-based authentication..."
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl reload sshd

# Disabling IPv6 (if not required)
log "Disabling IPv6..."
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# Securing the Bootloader
log "Securing the bootloader..."
# For Amazon Linux 2 or newer, GRUB2 is used
# Follow prompts to create a hashed password and replace <hashed-password> with the result
grub2-mkpasswd-pbkdf2
echo "set superusers='root'" >> /etc/grub.d/40_custom
echo "password_pbkdf2 root <hashed-password>" >> /etc/grub.d/40_custom
grub2-mkconfig -o /boot/grub2/grub.cfg

# Firewall Configuration
log "Configuring the firewall..."
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --set-target=DROP --permanent
firewall-cmd --reload

# Automatic Updates
log "Setting up automatic updates..."
yum install -y dnf-automatic
systemctl enable --now dnf-automatic-install.timer

# Custom checks to be added here
# Example:
# Custom check for Apache
check_apache() {
    systemctl is-active httpd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        log "Apache is not running."
    else
        log "Apache is running."
    fi
}

log "Server hardening completed."
