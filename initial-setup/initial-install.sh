#!/bin/bash

# Get the binary and extract it
wget https://github.com/crypto-com/chain-main/releases/download/v0.8.0-crossfire/chain-main_0.8.0-crossfire_Linux_x86_64.tar.gz -O /home/crypto-solutions/chain-main_0.8.0-crossfire_Linux_x86_64.tar.gz
sudo tar -zxvf /home/crypto-solutions/chain-main_0.8.0-crossfire_Linux_x86_64.tar.gz -O /usr/local/bin/chain-maind 

# Verify the version
VERSION=$(chain-maind version)
if [ $VERSION != "0.8.0-crossfire" ]
then
echo "The binary file is not the expected version it is reporting version: $VERSION"
echo "Exiting"
quit

# Not doing init because already have validator files
echo "Dont forget to copy your validator files"

# Download the and replace the Croeseid Testnet genesis.json by:
curl https://raw.githubusercontent.com/crypto-com/testnets/main/crossfire/genesis.json > ~/.chain-maind/config/genesis.json

# Verify genesis
if [[ $(sha256sum ~/.chain-maind/config/genesis.json | awk '{print $1}') = "074d99565111844edf1e9eb62069b7ad429484c41adcab1062447948b215c3c8" ]]
then echo "OK" 
else echo "Genesis file is not correct exiting"
fi

# Add minimum fee
sed -i.bak -E 's#^(minimum-gas-prices[[:space:]]+=[[:space:]]+)""$#\1"0.1basetcro"#' ~/.chain-maind/config/app.toml

# Fast Sync
sed -i.bak -E 's#^(persistent_peers[[:space:]]+=[[:space:]]+).*$#\1"1c43083bc3ed408a20ecd1738200e9ab48026b6b@54.251.113.42:26656,b8f999e37d8446e24862a71b6d4a004400947fe5@3.0.217.55:26656,9e9173fbdfe8d8ee84038782eec0777ee5f33548@3.0.188.186:26656"# ; s#^(create_empty_blocks_interval[[:space:]]+=[[:space:]]+).*$#\1"5s"#' ~/.chain-maind/config/config.toml
LASTEST_HEIGHT=$(curl -s https://crossfire.crypto.com/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LASTEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "https://crossfire.crypto.com/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"https://crossfire.crypto.com:443,https://crossfire.crypto.com:443\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" ~/.chain-maind/config/config.toml

# Create systemd service
echo "There is an automated script to set up the service located https://github.com/crypto-com/chain-main/tree/release/v0.8/networks"
