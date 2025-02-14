#!/bin/bash

#******************************************************************************
# * @file           : 2_PC_IotConfig.sh
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
LOAD_CONFIG_FILE="load_config.sh"
source $LOAD_CONFIG_FILE

# Store account id
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Check if IoT Thing exists
if aws iot describe-thing --thing-name "$THING_NAME" > /dev/null 2>&1; then
    echo "Warning: AWS IoT Thing '$THING_NAME' already exists. Continuing..."
else
    # Create an AWS IoT thing
    aws iot create-thing --thing-name "$THING_NAME"
    echo "Created AWS IoT Thing: $THING_NAME"
fi

# Check if IoT Thing Group exists
if aws iot describe-thing-group --thing-group-name "$THING_GROUP_NAME" > /dev/null 2>&1; then
    echo "Warning: AWS IoT Thing Group '$THING_GROUP_NAME' already exists. Continuing..."
else
    # Create an AWS IoT thing group and attach the thing to the group
    aws iot create-thing-group --thing-group-name "$THING_GROUP_NAME"
    echo "Created AWS IoT Thing Group: $THING_GROUP_NAME"
fi

# Add thing to group
aws iot add-thing-to-thing-group --thing-name "$THING_NAME" --thing-group-name "$THING_GROUP_NAME"
echo "Attached Thing $THING_NAME to Thing Group $THING_GROUP_NAME"

# Check if IoT Policy exists
if aws iot get-policy --policy-name "$AWS_IOT_POLICY" > /dev/null 2>&1; then
    echo "Warning: AWS IoT Policy '$AWS_IOT_POLICY' already exists. Continuing..."
else
    # Create an AWS IoT policy
    aws iot create-policy --policy-name "$AWS_IOT_POLICY" --policy-document "$IOT_POLICY_DOCUMENT"
    echo "Created AWS IoT Policy: $AWS_IOT_POLICY"
fi

# Retrieve AWS IoT data endpoint
NEW_DATA_ENDPOINT=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS --output text --query 'endpointAddress')
echo "AWS IoT Data Endpoint: $NEW_DATA_ENDPOINT"

# Extract the region from the endpoint URL
NEW_REGION=$(echo "$NEW_DATA_ENDPOINT" | awk -F '.' '{print $3}')

# Retrieve AWS IoT credential endpoint
NEW_CREDENTIAL_ENDPOINT=$(aws iot describe-endpoint --endpoint-type iot:CredentialProvider --output text --query 'endpointAddress')
echo "AWS IoT Credential Endpoint: $NEW_CREDENTIAL_ENDPOINT"

# Update the config file
# Update REGION
sed -i 's|"REGION": "[^"]*"|"REGION": "'"$NEW_REGION"'"|' $JSON_CONFIG_FILE

# Update DATA_ENDPOINT
sed -i 's|"DATA_ENDPOINT": "[^"]*"|"DATA_ENDPOINT": "'"$NEW_DATA_ENDPOINT"'"|' $JSON_CONFIG_FILE

# Update CRED_ENDPOINT
sed -i 's|"CRED_ENDPOINT": "[^"]*"|"CRED_ENDPOINT": "'"$NEW_CREDENTIAL_ENDPOINT"'"|' $JSON_CONFIG_FILE

# Check if Role Alias exists
ROLE_ALIAS_ARN=$(aws iot describe-role-alias --role-alias $ROLE_ALIAS_NAME --query 'roleAliasDescription.roleAliasArn')

if [ -n "$ROLE_ALIAS_ARN" ]; then
    echo "Warning: AWS IoT Role Alias '$ROLE_ALIAS_NAME' already exists."
else
    # Create a Token Exchange Role Alias and capture its ARN
    ROLE_ALIAS_ARN=$(aws iot create-role-alias --role-alias "$ROLE_ALIAS_NAME" --role-arn arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME --output text --query 'roleAliasArn')
    echo "Created Token Exchange Role Alias: $ROLE_ALIAS_NAME with ARN: $ROLE_ALIAS_ARN"
fi

# Update ROLE_ALIAS_ARN
sed -i 's|"Resource": "[^"]*"|"Resource": "'"$ROLE_ALIAS_ARN"'"|' $IOT_ROLE_ALIAS_POLICY_FILE

source $LOAD_CONFIG_FILE

# Check if the AWS IoT policy exists
if aws iot get-policy --policy-name "$IOT_ROLE_ALIAS_POLICY_NAME" > /dev/null 2>&1; then
    echo "Warning: AWS IoT Policy '$IOT_ROLE_ALIAS_POLICY_NAME' already exists."
else
    # Create the AWS IoT policy
    aws iot create-policy --policy-name "$IOT_ROLE_ALIAS_POLICY_NAME" --policy-document "$IOT_ROLE_ALIAS_POLICY_DOCUMENT"
    echo "Created AWS IoT Policy: $IOT_ROLE_ALIAS_POLICY_NAME"
fi

script_name=$(basename "$0")
echo "$script_name script execution completed."

