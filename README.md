# GreenGrass Lite

## 1. Description

AWS GreenGrass lite for STM32MP2

## 2. Prerequisites

- **[STM32MP257F-DK](https://www.st.com/en/evaluation-tools/stm32mp257f-dk.html)** : The device must be [set up](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP2_boards/STM32MP257x-DK/Let%27s_start/Populate_the_target_and_boot_the_image) and accessible over Ethernet or [Wi-Fi](https://wiki.st.com/stm32mpu/wiki/How_to_setup_a_WLAN_connection).
- **[Git Bash](https://git-scm.com/downloads)**: Required for windows users as it provides a Unix-like shell that ensures compatibility with the Linux-style commands used in the scripts.
- **AWS Account**: Access to an AWS account with permissions to manage IAM, IoT, and Greengrass.
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)**: Ensure the AWS CLI is installed and [configured](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) on your local machine.
- **SSH Access**: Ensure you can SSH into the STM32MP257 DK.

## 3. Repository Structure

```
├── gg_lite
├── config.json
├── IoTPolicyDocument.json
├── IoTRoleAliasPolicy.json
├── TokenExchangeAccessPolicyDocument.json
├── TokenExchangeRoleAssumePolicyDocument.json
├── load_config.sh
├── print_config.sh
├── execute.sh
├── 1_PC_IamConfig.sh
├── 2_PC_IotConfig.sh
├── 3_PC_ThingConfig.sh
├── 4_PC_GreengrassConfig.sh
├── 5_MPU_RunGGLite.sh
├── cleanup.sh
└── cleanup
    ├── IamConfig_Cleanup.sh
    └── IotConfig_Cleanup.sh
```

## 4. Setting up Greengrass Lite
### 4.1. Clone this Repository
On a PC with AWS CLI installed, clone this repository:

```bash
git clone https://github.com/stm32-hotspot/STM32MP2_AWS-IoT-Greengrass-nucleus-lite.git
cd STM32MP2_AWS-IoT-Greengrass-nucleus-lite
```

### 4.2. Update Required Configuration Parameters
Before running the configuration scripts, you need to update specific fields in the `config.json` file to match your setup.

- **BOARD_IP**: The IP address of your STM32MP2 DK. Update this to match your device's network address.
  
- **THING_NAME**: A unique name for your IoT Thing. This name will be used in AWS IoT to identify your Greengrass Core device.

- **THING_GROUP_NAME**: The name of the IoT Thing Group you want to create for organizing your Greengrass Core devices. It helps in managing multiple devices efficiently.

> Note: There are optional configuration change described [below](#72-optional-configuration-parameters)

### 4.3. Run the Scripts

After making the necessary updates to `config.json`, run the following commands to load the configuration and execute the setup:

  ```bash
  ./execute.sh
  ```

## 5. Viewing and Managing Greengrass Logs and Services  

All core services will be reported under the `greengrass-lite` target. View their statuses with:  

```sh
systemctl status --with-dependencies greengrass-lite.target
```  

Entire system logs can be viewed with:  

```sh
journalctl -a
```  

Individual service logs can be viewed with:  

```sh
journalctl -a -t <service-name>
```  

For example, to view deployment logs:  

```sh
journalctl -a -t ggdeploymentd
```  

To stop Greengrass Nucleus Lite, run:  

```sh
systemctl stop greengrass-lite.target
```  


## 6. Verifying Greengrass Core Functionality

There are two ways to check if the Greengrass Core is functioning properly:

- **Check in the AWS IoT Core Console**:
   - Log in to your AWS Management Console and navigate to the AWS IoT Core service. 
   - Your new greengrass core should populate under Manage > Greengrass devices > Core devices after a few minutes

- **Check device status using AWS CLI**

  ```bash
  aws greengrassv2 list-core-devices --status HEALTHY
  ```

## 7. First Greengrass Lite Deployment  

For deploying a BLE Gateway using Greengrass Lite, refer to the dedicated repository:  

🔗 [GreenGrass Lite BLE Gateway](https://github.com/stm32-hotspot/GreenGrass_Lite_BLE_Gateway)  

This repository provides detailed steps for setting up a BLE Gateway on Greengrass Lite, including:  
  
- Setting up BLE sensor nodes
- Configuring Gateway component
- Deploying and managing edge devices

Follow the instructions in the repository to complete the deployment.


## 8. Configuration Files

### 8.1. Policies
- **IoTPolicyDocument.json**: Defines the IoT policy document for the device.
- **IoTRoleAliasPolicy.json**: Defines Role alias policy. Updated by the *2_PC_IotConfig.sh* script
- **TokenExchangeAccessPolicyDocument.json**: Specifies the policy for Token Exchange access.
- **TokenExchangeRoleAssumePolicyDocument.json**: Defines the policy for Token Exchange role assumptions.

### 8.2. Optional Configuration Parameters

`config.json` file with the following parameters can be left as default, understanding them may help in future customization:

- **IoTConfiguration**:
  - **AWS_IOT_POLICY**: The IoT policy name for your Thing. Default is `"MyGreengrassV2IoTThingPolicy"`.
  - **ROLE_ALIAS_NAME**: The role alias for token exchange. Default is `"MyGreengrassCoreTokenExchangeRoleAlias"`.
  - **EXCHANGE_ROLE_POLICY**: Policy for Token Exchange access. Default is `"MyGreengrassV2TokenExchangeRoleAccess"`.
  - **ROLE_NAME**: Name of the IAM role for the Thing. Default is `"MyGreengrassV2TokenExchangeRole"`.
  - **IOT_ROLE_ALIAS_POLICY_NAME**: Policy name for the role alias. Default is `"MyGreengrassCoreTokenExchangeRoleAliasPolicy"`.
  - **REGION**: AWS region for the IoT resources. Updated by the *2_PC_IotConfig.sh* script
  - **DATA_ENDPOINT** : Endpoint address. Updated by the *2_PC_IotConfig.sh* script
  - **CRED_ENDPOINT** : Credential Endpoint address. Updated by the *2_PC_IotConfig.sh* script

## 9. Script Summary

### 9.1. load_config.sh

Parses the various configuration JSON files and exports their contents as environment variables. This script should be run before executing any of the others.

### 9.2. 1_PC_IamConfig.sh

Sets up AWS IAM roles and policies for the device by:

- Loading the necessary configuration from the environment variables set by `load_config.sh`.
- Creates the IAM roles and policies required for Greengrass V2 setup.

### 9.2. 2_PC_IotConfig.sh

Configures AWS IoT resources

### 9.2. 3_PC_ThingConfig.sh

Create a Thing in AWS and download the certs to ./gg_lite/certs

### 9.3. 4_PC_GreengrassConfig.sh

Updates the init_config.yml file

### 9.4. 5_MPU_RunGGLite.sh

Configures and restarts the Greengrass Core service:

- Updates `config.yaml` with security settings and AWS resource details.

### 9.5. execute.sh

Orchestrates the execution of all configuration scripts:

- Copies the local configuration and gg_lite to the STM32MP2 DK.
- Install and run gg_lite on STM32MP2 DK.

## 10. Cleanup Scripts

After configuring the STM32MP2 DK as an AWS Greengrass Core device, you can use the provided cleanup scripts to remove the AWS resources created during the setup. These scripts will handle the deletion of IAM roles, IoT Things, certificates, policies, and other associated resources.

`cleanup.sh` calls both of the following cleanup scripts:

 - `IamConfig_Cleanup.sh` : Deletes IAM resources 
 - `IotConfig_Cleanup.sh` : Deletes IoT resources

Usage:
```bash
./cleanup.sh
```
> **Note**: Ensure that `config.json` has been updated with the desired configuration you would like to delete before executing these cleanup scripts.

By running these scripts, you can ensure a clean removal of resources created during the configuration of the STM32MP2 DK as a Greengrass Core device.


### 10.1. IamConfig_Cleanup.sh

This script removes the IAM resources that were created during the configuration process:

- Deletes all inline policies attached to the specified IAM role.
- Deletes the IAM role itself if it exists.

Usage:
```bash
./cleanup/IamConfig_Cleanup.sh
```

### 10.2. IotConfig_Cleanup.sh

This script removes the IoT and Greengrass resources:

- Deletes the IoT Role Alias.
- Detaches and deletes all policies attached to the IoT certificates.
- Deactivates, revokes, and deletes certificates associated with the IoT Thing.
- Deletes the IoT Thing and its associated Thing Group.
- Deletes the Greengrass Core device for the STM32MP2 DK.

Usage:
```bash
./cleanup/IotConfig_Cleanup.sh
```