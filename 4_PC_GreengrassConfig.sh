#!/bin/bash

#******************************************************************************
# * @file           : 4_PC_GreengrassConfig.sh
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

# Source the configuration file
LOAD_CONFIG_FILE="./load_config.sh"
source $LOAD_CONFIG_FILE

sed -i "s/thingName: .*/thingName: \"${THING_NAME}\"/g" ./gg_lite/config.yaml
sed -i "s/awsRegion: .*/awsRegion: \"${REGION}\"/g" ./gg_lite/config.yaml
sed -i "s/iotCredEndpoint: .*/iotCredEndpoint: \"${CRED_ENDPOINT}\"/g" ./gg_lite/config.yaml
sed -i "s/iotDataEndpoint: .*/iotDataEndpoint: \"${DATA_ENDPOINT}\"/g" ./gg_lite/config.yaml
sed -i "s/iotRoleAlias: .*/iotRoleAlias: \"${ROLE_ALIAS_NAME}\"/g" ./gg_lite/config.yaml

script_name=$(basename "$0")
echo "$script_name script execution completed."