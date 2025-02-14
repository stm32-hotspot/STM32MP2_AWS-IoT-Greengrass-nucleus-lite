#!/bin/bash

#******************************************************************************
# * @file           : IamConfig_Cleanup.sh
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

# set -e  # Exit immediately if a command exits with a non-zero status

# Source the configuration file
CONFIG_FILE="./load_config.sh"
source $CONFIG_FILE

# Step 2: Delete all inline policies from the role
echo "Listing inline policies for role '$ROLE_NAME'..."
INLINE_POLICIES=$(aws iam list-role-policies --role-name "$ROLE_NAME" --query 'PolicyNames' --output text)

if [ -n "$INLINE_POLICIES" ]; then
    for POLICY_NAME in $INLINE_POLICIES; do
        echo "Deleting inline policy '$POLICY_NAME' from role '$ROLE_NAME'..."
        aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME"
    done
else
    echo "No inline policies for role '$ROLE_NAME'."
fi


# Delete the IAM Role
if aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1; then
    echo "Deleting IAM Role '$ROLE_NAME'..."
    aws iam delete-role --role-name "$ROLE_NAME"
    echo "Deleted IAM Role: $ROLE_NAME"
else
    echo "IAM Role '$ROLE_NAME' does not exist."
fi


# Delete the IoT Role Alias
echo "Deleting IoT Role Alias '$ROLE_ALIAS_NAME'..."
aws iot delete-role-alias --role-alias "$ROLE_ALIAS_NAME" || echo Warning failed to delete role alias: ${ROLE_ALIAS_NAME}

echo "IAM Cleanup script execution completed."
