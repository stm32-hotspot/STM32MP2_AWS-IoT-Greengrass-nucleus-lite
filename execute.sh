#!/bin/bash

#******************************************************************************
# * @file           : execute.sh
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

# Source the config file
LOAD_CONFIG_FILE="load_config.sh"
source $LOAD_CONFIG_FILE

MPU_GG_CONFIG_SCRIPT="5_MPU_RunGGLite.sh"

# Function to copy file to the board
copy_file_to_board() {
    local FILE_TO_COPY="$1"
    REMOTE_FILE_PATH=${REMOTE_SCRIPT_PATH}${FILE_TO_COPY}
    scp $FILE_TO_COPY root@$BOARD_IP:$REMOTE_FILE_PATH    
    # Update the line ending
    ssh root@$BOARD_IP "sed -i.bak 's/\r$//' $REMOTE_FILE_PATH"

    if [ $? -ne 0 ]; then
        echo "Failed to copy $FILE_TO_COPY file to the board."
        exit 1
    fi

   #Delete the backup file
    ssh root@$BOARD_IP "rm $REMOTE_FILE_PATH.bak"
}

# Function to execute a script on the board
run_script_on_board() {
    local script_name="$1"
    ssh root@$BOARD_IP "bash ${REMOTE_SCRIPT_PATH}${script_name}"
    if [ $? -ne 0 ]; then
        echo "Failed to run $script_name on the board."
        exit 1
    fi
}

# Function to source a script on the board
source_script_on_board() {
    local script_name="$1"
    echo "Sourcing $script_name on the board..."
    ssh root@$BOARD_IP "source ${REMOTE_SCRIPT_PATH}${script_name}"
}

check_ssh(){
    port=22

    if timeout 5 bash -c "</dev/tcp/$BOARD_IP/$port"; then
      echo "SSH is available on $BOARD_IP"
    else
      echo "SSH is not available on $BOARD_IP"
      exit 1
    fi
}

# Check if remote server is available
check_ssh

echo "Running PC IAM configuration script..."
bash 1_PC_IamConfig.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute 1_PC_IamConfig.sh on the PC."
    exit 1
fi

echo "Running PC IoT configuration script..."
bash 2_PC_IotConfig.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute 2_PC_IotConfig.sh on the PC."
    exit 1
fi

echo "Running PC Thing configuration script..."
bash 3_PC_ThingConfig.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute 3_PC_ThingConfig.sh on the PC."
    exit 1
fi

echo "Downloading AmazonRootCA1.pem"
curl -o ./gg_lite/certs/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem

echo "Running PC Greengrass configuration script..."
bash 4_PC_GreengrassConfig.sh
if [ $? -ne 0 ]; then
    echo "Failed to execute 4_PC_GreengrassConfig.sh on the PC."
    exit 1
fi

echo "Copying gg_lite files to STM32MP ..."
scp -r ./gg_lite root@$BOARD_IP:$REMOTE_SCRIPT_PATH

echo "Copying $MPU_GG_CONFIG_SCRIPT to the board..."
copy_file_to_board $MPU_GG_CONFIG_SCRIPT

echo "Running $MPU_GG_CONFIG_SCRIPT on the STM32MP board..."
run_script_on_board $MPU_GG_CONFIG_SCRIPT

echo "All scripts executed successfully."
