# Coti Node Upgrade Script
A script to easily upgrade a coti full node that was originally installed with the wolf install script.

Please run the script as the root user by logging in as root. Copy and paste the code below into your node after logging in. This script assumes you installed your node with the wolf install script at https://medium.com/wolf-crypto/how-to-setup-a-coti-testnet-node-on-vultr-a3710d24f892

If you have any issues, you can catch me on telegram or discord.
```
cd ~
rm -rf upgrade.sh
wget -O upgrade.sh https://raw.githubusercontent.com/Geordie-R/coti-node-upgrade/main/upgrade.sh && chmod +x upgrade.sh
./upgrade.sh
```
