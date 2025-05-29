#!/bin/bash

#******************************************************************************
# * @file           : 5_MPU_RunGGLite.sh
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


GG_DIR="/home/root/gg_lite/"

# Install dependencies
dpkg -i ${GG_DIR}libzip_1.10.1-r0.0_arm64.deb
dpkg -i ${GG_DIR}uriparser_0.9.8-r0.0_arm64.deb 

# Extract files
tar xvf ${GG_DIR}gglite.gz -C /home/root/

# Change ownership of extracted files
chown -R root:root /home/root/aws-greengrass-lite/

# Copy system files to device
cp /home/root/aws-greengrass-lite/lib/systemd/system/* /lib/systemd/system/.

# Copy certs to cert directory
cp -r ${GG_DIR}certs /home/root/certs 

# Make run directory
mkdir -p /var/lib/greengrass

# Make config directory
mkdir -p /etc/greengrass

# Copy config file to config directory
cp ${GG_DIR}config.yaml /etc/greengrass

# Run nucleus
sed -i 's/\r$//' ${GG_DIR}run_nucleus
chmod +x ${GG_DIR}run_nucleus
${GG_DIR}run_nucleus