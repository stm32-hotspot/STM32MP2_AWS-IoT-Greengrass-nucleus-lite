#!/bin/bash

#******************************************************************************
# * @file           : load_config.sh
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

JSON_CONFIG_FILE="config.json"
IOT_POLICY_FILE="IoTPolicyDocument.json"
TOKEN_EXCHANGE_POLICY_FILE="TokenExchangeRoleAssumePolicyDocument.json"
TOKEN_EXCHANGE_ACCESS_POLICY_FILE="TokenExchangeAccessPolicyDocument.json"
IOT_ROLE_ALIAS_POLICY_FILE="IoTRoleAliasPolicy.json"
LOAD_CONFIG_FILE="load_config.sh"
PRINT_CONFIG_FILE="print_config.sh"
MPU_GG_CONFIG_SCRIPT="4_MPU_greengrassConfig.sh"

# Function to extract values from JSON
extract_value() {
    local key=$1
    grep -oP '"'"$key"'"\s*:\s*"\K[^"]+' $JSON_CONFIG_FILE
}

# Parse JSON and assign variables
export BOARD_IP=$(extract_value 'BOARD_IP')
export REMOTE_SCRIPT_PATH=$(extract_value 'REMOTE_SCRIPT_PATH')

# Export the configuration file
export JSON_CONFIG_FILE="config.json"
export IOT_POLICY_FILE="IoTPolicyDocument.json"
export TOKEN_EXCHANGE_POLICY_FILE="TokenExchangeRoleAssumePolicyDocument.json"
export TOKEN_EXCHANGE_ACCESS_POLICY_FILE="TokenExchangeAccessPolicyDocument.json"
export IOT_ROLE_ALIAS_POLICY_FILE="IoTRoleAliasPolicy.json"
export LOAD_CONFIG_FILE="load_config.sh"
export PRINT_CONFIG_FILE="print_config.sh"
export MPU_GG_CONFIG_SCRIPT="4_MPU_greengrassConfig.sh"

export THING_NAME=$(extract_value 'THING_NAME')
export THING_GROUP_NAME=$(extract_value 'THING_GROUP_NAME')
export AWS_IOT_POLICY=$(extract_value 'AWS_IOT_POLICY')
export ROLE_ALIAS_NAME=$(extract_value 'ROLE_ALIAS_NAME')
export EXCHANGE_ROLE_POLICY=$(extract_value 'EXCHANGE_ROLE_POLICY')
export ROLE_NAME=$(extract_value 'ROLE_NAME')
export IOT_ROLE_ALIAS_POLICY_NAME=$(extract_value 'IOT_ROLE_ALIAS_POLICY_NAME')

export REGION=$(extract_value 'REGION')
export DATA_ENDPOINT=$(extract_value 'DATA_ENDPOINT')
export CRED_ENDPOINT=$(extract_value 'CRED_ENDPOINT')

# Load the JSON content into variables
if [ -f "$IOT_POLICY_FILE" ]; then
  export IOT_POLICY_DOCUMENT=$(cat ${IOT_POLICY_FILE})
fi

if [ -f "$TOKEN_EXCHANGE_POLICY_FILE" ]; then
  export TOKEN_EXCHANGE_POLICY_DOCUMENT=$(cat ${TOKEN_EXCHANGE_POLICY_FILE})
fi

if [ -f "$TOKEN_EXCHANGE_ACCESS_POLICY_FILE" ]; then
  export TOKEN_EXCHANGE_ACCESS_POLICY_DOCUMENT=$(cat ${TOKEN_EXCHANGE_ACCESS_POLICY_FILE})
fi

if [ -f "$IOT_ROLE_ALIAS_POLICY_FILE" ]; then
  export IOT_ROLE_ALIAS_POLICY_DOCUMENT=$(cat ${IOT_ROLE_ALIAS_POLICY_FILE})
fi
