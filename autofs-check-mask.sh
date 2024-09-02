#!/bin/bash
################################################################################
# Script Name: autofs-check-mask.sh
# Description: Hardens autofs settings on the system by stopiing and masking it.
# Author: https://github.com/fallen-man with modifications by mnikolov (https://github.com/mnikolov/ubuntu-22-04-cis-hardening)
# Version: 0.2 2024-SEP-03
################################################################################

# Check if the autofs.service is enabled.
outcome=$(systemctl is-enabled autofs --quiet 2>/dev/null)

# if there is an error checking the status of autofs or autofs.service is not installed, exit the script.
if [ "$?" -ne 0 ]; then
    echo "Error checking status of autofs or autofs.service is not installed."
    exit 0
fi

if [ "$outcome" == "enabled" ]; then
    sudo systemctl stop autofs
    sudo systemcttl mask autofs
    echo "autofs.service stopped and masked"
else
    echo "autofs.service already disabled"
fi
