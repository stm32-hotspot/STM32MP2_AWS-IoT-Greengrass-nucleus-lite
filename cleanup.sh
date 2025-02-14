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

# Function to delete a file from the board
delete_file_from_board() {
    local FILE_TO_DELETE="$1"
    REMOTE_FILE_PATH=${REMOTE_SCRIPT_PATH}${FILE_TO_DELETE}
    echo "Deleting $FILE_TO_DELETE from to the board..."
    ssh root@$BOARD_IP "rm $REMOTE_FILE_PATH"
}

LOAD_CONFIG_FILE="./load_config.sh"
source $LOAD_CONFIG_FILE

source cleanup/IotConfig_Cleanup.sh
source cleanup/IamConfig_Cleanup.sh

# Delete the configuration files from the board
# delete_file_from_board $MPU_GG_CONFIG_SCRIPT

script_name=$(basename "$0")
echo "$script_name script execution completed."
