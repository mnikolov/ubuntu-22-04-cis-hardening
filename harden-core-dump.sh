#!/bin/bash
################################################################################
# Script Name: harden-core-dump.sh
# Description: Hardens core dump settings on the system in a manner that prevents system information leakage.
# Author: https://github.com/fallen-man with modifications by mnikolov (https://github.com/mnikolov/ubuntu-22-04-cis-hardening)
# Version: 0.2 2024-SEP-03
################################################################################
outputfile="/etc/sysctl.d/60-kernel-cis-benchmarks.conf"
coredumplimitsfile = "/etc/security/limits.d/coredump"
coredumpconf = "/etc/systemd/coredump.conf"

outcome=$(systemctl is-enabled coredump --quiet 2>/dev/null)
if [ "$?" -ne 0 || "$outcome" != "enabled" ]; then
    echo "Coredump service is not installed or not available. Updating package lists and installing systemd-coredump."
    # Update package lists and install systemd-coredump
    apt update
    apt install systemd-coredump
fi

# Create /etc/security/limits.d/coredump with the specified content
echo "* hard core 0" > $coredumplimitsfile

# Add hardening requirements to the kernel CIS benchmarks config file
echo "fs.suid_dumpable = 0" >> $outputfile

# Set core dumping to disabled in the kernel running configuration
sysctl -w fs.suid_dumpable=0

# Edit /etc/systemd/coredump.conf to add or modify the specified lines
sed -i 's/^#\?\(Storage=\).*/\1none/' $coredumpconf
sed -i 's/^#\?\(ProcessSizeMax=\).*/\10/' $coredumpconf

# Run systemctl daemon-reload
systemctl daemon-reload
