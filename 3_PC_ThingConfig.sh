#!/bin/bash

#******************************************************************************
# * @file           : 3_PC_ThingConfig.sh
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

set -e  # Exit immediately if a command exits with a non-zero status

# Source the configuration file
LOAD_CONFIG_FILE="load_config.sh"
source $LOAD_CONFIG_FILE

CERTS_DIR="./gg_lite/certs"

# Ask the user if they want to delete the certs directory
if [ -d "$CERTS_DIR" ]; then
    echo -e "\033[0;33mWARNING: The directory '$CERTS_DIR' already exists. Do you want to delete it? (y/n)\033[0m"
    read response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo "Deleting the certs directory..."
        rm -rf "$CERTS_DIR"
        echo "Recreating the certs directory..."
        mkdir -p "$CERTS_DIR"
    else
        exit 1 # change to exit 0 if you want to execution with current certs directory
    fi
else
    echo "Creating certs directory..."
    mkdir -p "$CERTS_DIR"
fi

# Generate file paths
CERTIFICATE_FILE="$CERTS_DIR/certificate.pem"
PUBLIC_KEY_FILE="$CERTS_DIR/public.key"
PRIVATE_KEY_FILE="$CERTS_DIR/private.key"


echo "Creating a new $THING_NAME Thing"
aws iot create-thing --thing-name $THING_NAME

echo "Create keys and certificate"
CERT_ARN=$(aws iot create-keys-and-certificate --set-as-active --certificate-pem-outfile $CERTIFICATE_FILE --public-key-outfile $PUBLIC_KEY_FILE --private-key-outfile $PRIVATE_KEY_FILE --query 'certificateArn' --output text)

echo "Certificate ARN: ${CERT_ARN}"

echo "Attaching certificate to IoT Thing..."
aws iot attach-thing-principal --thing-name ${THING_NAME} --principal ${CERT_ARN}
if [ $? -ne 0 ]; then
    echo "Failed to attach certificate to IoT Thing."
    exit 1
fi

# Attach policy to certificate
echo "Attaching IoT policy to certificate..."
aws iot attach-policy --policy-name ${AWS_IOT_POLICY} --target ${CERT_ARN}
if [ $? -ne 0 ]; then
    echo "Failed to attach policy to certificate."
    exit 1
fi

# Attach policy to certificate
echo "Attaching role alias policy to certificate..."
aws iot attach-policy --policy-name ${IOT_ROLE_ALIAS_POLICY_NAME} --target ${CERT_ARN}
if [ $? -ne 0 ]; then
    echo "Failed to attach policy to certificate."
    exit 1
fi


script_name=$(basename "$0")
echo "$script_name script execution completed."
