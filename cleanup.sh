#!/bin/bash

#******************************************************************************
# * @file           : cleanup.sh
# * @brief          : 
# ******************************************************************************
# * @attention
# *
# * <h2><center>&copy; Copyright (c) 2022 STMicroelectronics.
# * All rights reserved.</center></h2>
# *
# * This software component is licensed by ST under BSD 3-Clause license,
# * the "License"; You may not use this file except in compliance with the
# * License. You may obtain a copy of the License at:
# *                        opensource.org/licenses/BSD-3-Clause
# ******************************************************************************

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

LOAD_CONFIG_FILE="./load_config.sh"
source $LOAD_CONFIG_FILE

check_ssh() {
  ssh -o ConnectTimeout=5 root@"$BOARD_IP" "exit" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "SSH is available on $BOARD_IP"
  else
    echo "SSH is not available on $BOARD_IP"
    exit 1
  fi
}

# SSH command wrapper
run_remote_cmd() {
    echo "[MPU] $1"
    ssh root@"$BOARD_IP" "$1"
}


# Check if remote server is available
check_ssh

source cleanup/IotConfig_Cleanup.sh
source cleanup/IamConfig_Cleanup.sh

# Stop and disable Greengrass services on MPU
run_remote_cmd "systemctl stop greengrass-lite.target || true"
run_remote_cmd "systemctl disable greengrass-lite.target || true"

# Remove systemd service files on MPU
run_remote_cmd "rm -f /etc/systemd/system/greengrass-lite.target"

# Delete Greengrass-related directories and files on MPU (one by one)
echo "Deleting Greengrass files from MPU..."
run_remote_cmd "rm -f /etc/systemd/system/greengrass-lite.target" || echo "Warning: Failed to /etc/systemd/system/greengrass-lite.target"
run_remote_cmd "rm -rf /home/root/5_MPU_RunGGLite.sh" || echo "Warning: Failed to delete /home/root/5_MPU_RunGGLite.sh"
run_remote_cmd "rm -rf /home/root/aws-greengrass-lite/" || echo "Warning: Failed to delete /home/root/aws-greengrass-lite/"
run_remote_cmd "rm -rf /home/root/certs/" || echo "Warning: Failed to delete /home/root/certs/"
run_remote_cmd "rm -rf /home/root/gg_lite/" || echo "Warning: Failed to delete /home/root/gg_lite/"
run_remote_cmd "rm -rf /etc/greengrass/" || echo "Warning: Failed to delete /etc/greengrass/"
run_remote_cmd "rm -rf /var/lib/greengrass" || echo "Warning: Failed to delete /var/lib/greengrass"



script_name=$(basename "$0")
echo "$script_name script execution completed."
