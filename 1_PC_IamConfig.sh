#!/bin/bash

#******************************************************************************
# * @file           : 1_PC_IamConfig.sh
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

echo $TOKEN_EXCHANGE_POLICY_DOCUMENT
echo $TOKEN_EXCHANGE_ACCESS_POLICY_DOCUMENT

# Store account id
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Check if IAM Role exists
if aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1; then
    echo "Warning: IAM Role '$ROLE_NAME' already exists."
else
    # Create a Token Exchange Role
    aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TOKEN_EXCHANGE_POLICY_DOCUMENT"
    echo "Created IAM Role: $ROLE_NAME"
fi

# Check if IAM Role Policy exists
if aws iam get-role-policy --role-name "$ROLE_NAME" --policy-name "$EXCHANGE_ROLE_POLICY" > /dev/null 2>&1; then
    echo "Warning: IAM Role Policy '$EXCHANGE_ROLE_POLICY' already exists for role '$ROLE_NAME'."
else
    # Attach the Token Exchange Role Access Policy
    aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "$EXCHANGE_ROLE_POLICY" --policy-document "$TOKEN_EXCHANGE_ACCESS_POLICY_DOCUMENT"
    echo "Attached Access Policy to Role: $ROLE_NAME"
fi

script_name=$(basename "$0")
echo "$script_name script execution completed."
