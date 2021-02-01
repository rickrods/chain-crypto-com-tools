#!/bin/bash

# Retrieve the software
mkdir -p ~/crossfire
wget https://github.com/crypto-com/chain-main/releases/download/v0.8.1-crossfire/chain-main_0.8.1-crossfire_Linux_x86_64.tar.gz -O ~/crossfire
tar -zxvf ~/crossfire/chain-main_0.8.1-crossfire_Linux_x86_64.tar.gz && cd chain-main_0.8.1-crossfire_Linux_x86_64


# Stop the running service
sudo systemctl stop chain-maind.service

# Update the binary
sudo cp chain-maind /usr/local/bin/

# Check version
VERSION=$(chain-maind version)
if [ $VERSION != "0.8.1-crossfire" ]
then
echo "The binary file is not the expected version it is reporting version: $VERSION"
echo "Exiting"
quit

# Remove the address book
rm ~/.chain-maind/config/addrbook.json

# Increase your memory pool size:   
OLDPOOL="size = 5000"
NEWPOOL="size = 20000"
sed 's/"$OLDPOOL"/"$NEWPOOL"/g'  ~/.chain-maind/config/config.toml

# Start the service with the new files and settings
sudo systemctl start chain-maind.service
