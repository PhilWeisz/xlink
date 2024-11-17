#!/bin/bash

# Paths and Variables
LINK_MANAGER_SCRIPT="./link_manager.sh"
CONFIG_FILE="/u/a/i/linkmgr/link_config.cfg"
USB_DRIVE="/dev/sdX"        # Replace with your USB device (e.g., sdb)
MOUNT_POINT="/u/installer_usb"
ISO_DIR="/u/installer_usb/files/iso" # Directory containing your ISO files
GRUB_CFG="$MOUNT_POINT/boot/grub/grub.cfg"
ISO_DEST="$MOUNT_POINT/boot/isos"

# Step 1: Run Link Manager
echo "Running the link manager to set up configuration links..."
$LINK_MANAGER_SCRIPT process
if [[ $? -ne 0 ]]; then
    echo "Error: Link manager failed. Aborting."
    exit 1
fi
