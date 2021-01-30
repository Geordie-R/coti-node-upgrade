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

## Corrupt database?
If you get a corrupt database run the following code to set a reset.transactions=true in your config and restart your cnode.service.

```

cd ~
rm -rf reset_transactions.sh
wget -O reset_transactions.sh https://raw.githubusercontent.com/Geordie-R/coti-node-upgrade/main/reset_transactions.sh && chmod +x reset_transactions.sh
./reset_transactions.sh "true"
```

## Reboot the cnode.service
sudo systemctl stop cnode.service
sudo systemctl start cnode.service

```
Finally once your node is back up and running, set the reset to false so that we dont wipe the transactions on the next reboot.
```
./reset_transactions.sh "false"
```

