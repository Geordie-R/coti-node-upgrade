##!/bin/bash

# ██████╗ ██████╗ ████████╗██╗    ███╗   ██╗ ██████╗ ██████╗ ███████╗    ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ ██████╗ ███████╗
#██╔════╝██╔═══██╗╚══██╔══╝██║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝    ██║   ██║██╔══██╗██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝
#██║     ██║   ██║   ██║   ██║    ██╔██╗ ██║██║   ██║██║  ██║█████╗      ██║   ██║██████╔╝██║  ███╗██████╔╝███████║██║  ██║█████╗
#██║     ██║   ██║   ██║   ██║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝      ██║   ██║██╔═══╝ ██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝
#╚██████╗╚██████╔╝   ██║   ██║    ██║ ╚████║╚██████╔╝██████╔╝███████╗    ╚██████╔╝██║     ╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗
# ╚═════╝ ╚═════╝    ╚═╝   ╚═╝    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 ######### Unofficial upgrade script by mainnet node node operator GeordieR ##########

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
COLOR_RESET=$(tput sgr0)


#Make sure running as the root user
if [ "$EUID" -ne 0 ]
  then echo "${RED}PLEASE RUN AS ROOT USER${COLOR_RESET}"
  exit
fi


#Parameters
filename="/etc/systemd/system/cnode.service"
node_folder="coti-node"
default_user="coti"
#Install JQ which makes it easy to interpret JSON
apt-get update -y
apt-get install -y jq


shopt -s globstar dotglob

cat << "MENUEOF"
███╗   ███╗███████╗███╗   ██╗██╗   ██╗
████╗ ████║██╔════╝████╗  ██║██║   ██║
██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝
MENUEOF

PS3='Please choose what node you are upgrading today.  Mainnet or Testnet node. Please write the number of the menu item and press enter: '
mainnet="Upgrade an existing node on the COTI mainnet"
testnet="Upgrade an existing node on the COTI testnet"
cancelit="Cancel"
options=("$mainnet" "$testnet" "$cancelit")
#asktorestart=0
select opt in "${options[@]}"
do
    case $opt in
        "$mainnet")
        action="mainnet"
        echo "You chose a mainnet node install"
        sleep 1
         break
            ;;
        "$testnet")
            echo "You chose a TESTNET node install"
        action="testnet"
        sleep 1
        break
            ;;
       "$cancelit")
            echo "${RED}You chose to cancel${COLOR_RESET}"
        action="cancel"
        exit 1
break
            ;;
        "Quit")
            exit 1
break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



read -p "What is your ubuntu username you used for your original node install (leave it blank and it will default to coti) ?: " username


if [[ $username == "" ]]; then

username=$default_user

fi



if id "$username" >/dev/null 2>&1; then
        echo "Great the user exists!"
else
  echo "${RED}The chosen user $username does not exist. The script will now exit.${COLOR_RESET}"
exit 1
fi


cd /home/$username/$node_folder/



function removequotes(){
  #Remove the front and end double quote
  version=${1#"\""}
  version=${version%"\""}
  echo "$version"
}

new_version_tag_final=""
new_version_tag=$(curl -s https://api.github.com/repos/coti-io/$node_folder/releases/latest | jq ".tag_name")


#Remove the front and end double quote
new_version_tag=$(removequotes "$new_version_tag")
testnet_version="3.1.1"
coti_dir=""

echo "Latest version for mainnet is $new_version_tag"



extra_vers_desc=""
if [[ $action == "testnet" ]];
then
extra_vers_desc="If you leave this empty, it will use the latest version."
elif [[ $action == "mainnet" ]];
then
extra_vers_desc="If you leave this empty, the script will terminate."

fi

read -p "What version node software would you like to use. If you are on mainnet, or if you are an exchange, this should have been communicated to you from COTI. $extra_vers_desc. If entering a version number, remember it takes this format: 3.1.0 ?: " new_version_tag_final





# If we are on mainnet and a version isnt chosen, terminate the script
if [[ $action == "mainnet" ]] && [[ $new_version_tag_final == "" ]];
then
echo "${RED}No version chosen.  Terminating script. ${COLOR_RESET}"
exit 1
elif [[ $action == "testnet" ]] && [[ $new_version_tag_final == "" ]];
then
echo "${YELLOW}No version chosen, that's ok, selecting latest version.${COLOR_RESET}"
new_version_tag_final=$testnet_version
fi


# Finally if the user wrote 'latest' then it will pull the latest version!
if [[ $new_version_tag_final == "latest" ]];
then
new_version_tag_final=$new_version_tag
fi

echo "Chosen version is $new_version_tag_final"






release_or_snap=""
PSR='Please choose what you are installing a RELEASE or a SNAPSHOT. Usually its a RELEASE but if unsure always ask COTI admins or in discord. Please write the number of the menu item and press enter:'
rel="Its a RELEASE (This is the most common option)"
snap="Its a SNAPSHOT"
cancelitx="Cancel"
optionsx=("$rel" "$snap" "$cancelitx")
select optx in "${optionsx[@]}"
do
    case $optx in
        "$rel")
        release_or_snap="RELEASE"
        echo "You chose RELEASE"
        sleep 1
         break
            ;;
        "$snap")
            echo "You chose SNAPSHOT"
        release_or_snap="SNAPSHOT"
        sleep 1
        break
            ;;
       "$cancelitx")
            echo "${RED}You chose to cancel at the RELEASE / SNAPSHOT section${COLOR_RESET}"
        release_or_snap="cancel"
        exit 1
break
            ;;
        "Quit")
            exit 1
break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done



#Backup the fullnode.properties file to home folder
cd /home/$username/
cp /home/$username/$node_folder/fullnode.properties /home/$username/
#Remove the node folder
rm -R /home/$username/$node_folder/
#Download new node version
git clone --depth 1 --branch $new_version_tag_final https://github.com/coti-io/$node_folder/
#Copy the fullnode.properties file back
cp /home/$username/fullnode.properties /home/$username/$node_folder/fullnode.properties


chown -R $username: /home/$username/$node_folder/
cd /home/$username/$node_folder/
#BUILD!
mvn initialize && mvn clean compile && mvn -Dmaven.test.skip=true package



new_jar_name="fullnode-$new_version_tag_final.$release_or_snap.jar"


#Get full cnode.service inside a variable
cnode_file=$(<$filename)
#Get everything after the phrase below
after_fullnode=${cnode_file#*"/coti-node/fullnode/target/"}
#Now split whats after the phrase into seperate words
stringarray=($after_fullnode)
#Now take the first word which should look sokmething like fullnode-1.4.0.RELEASE.jar
old_jar_name=${stringarray[0]}

echo "old jar name is $old_jar_name"

if [[ "$old_jar_name" != "$new_jar_name" ]]; then
echo "New Version Found! - You have $old_jar_name referenced in your /etc/systemd/system/cnode.service file and the new version is $new_jar_name"
echo "Replacing version in cnode.service file"
sed -i "s/$old_jar_name/$new_jar_name/" $filename
echo "Process complete! - Please re-read over the outputs above for any errors"
else
  echo "echo ${YELLOW}You have the same version: $new_jar_name that is listed in the cnode.service file compared to github. No changes needed${COLOR_RESET}"
echo "Process complete"
fi

echo "Moving on to clusterstamp"

#########################################
# Download Clusterstamp
#########################################

FILE=/home/$username/$node_folder/FullNode1_clusterstamp.csv

cluster_url_mainnet="https://coti.tips/downloads/FullNode1_clusterstamp.csv"
cluster_url_testnet="https://www.dropbox.com/s/rpyercs56zmay0z/FullNode1_clusterstamp.csv"

if [[ $action == "testnet" ]];
then
  echo "${YELLOW}Downloading the clusterstamp now from ... ${COLOR_RESET}"
  #wget "$FILE" $cluster_url_testnet
  wget --show-progress --progress=bar:force 2>&1 $cluster_url_testnet -P /home/$username/$node_folder/
elif [[ $action == "mainnet" ]];
then
echo "${YELLOW}Downloading the mainnet clusterstamp now from ... ${COLOR_RESET}"
#  wget "$FILE" $cluster_url_mainnet
  wget --show-progress --progress=bar:force 2>&1 $cluster_url_mainnet -P /home/$username/$node_folder/
fi

echo "Applying chgrp and chown to clusterstamp and properties"
chown $username /home/$username/$node_folder/FullNode1_clusterstamp.csv
chgrp $username /home/$username/$node_folder/FullNode1_clusterstamp.csv
chown $username /home/$username/$node_folder/fullnode.properties
chgrp $username /home/$username/$node_folder/fullnode.properties

echo "Reloading systemctl daemon"
systemctl daemon-reload
echo "Restarting cnode.service"
systemctl restart cnode.service
sleep 5
status=$(systemctl is-active cnode.service)

if [[ "$status" == "active" ]]; then

logging_file_name="FullNode1"
log_path="/home/$username/$node_folder/logs/$logging_file_name.log"
echo "Viewing $log_path #<#<#"
tail -f $log_path | while read line; do
echo $line
echo ${GREEN}$line${COLOR_RESET}| grep -q 'COTI FULL NODE IS UP' && break;
done

cat << "UPGRADEEOF"

██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ ██████╗ ███████╗
██║   ██║██╔══██╗██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝
██║   ██║██████╔╝██║  ███╗██████╔╝███████║██║  ██║█████╗
██║   ██║██╔═══╝ ██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝
╚██████╔╝██║     ╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗
 ╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝

 ██████╗ ██████╗ ███╗   ███╗██████╗ ██╗     ███████╗████████╗███████╗██╗
██╔════╝██╔═══██╗████╗ ████║██╔══██╗██║     ██╔════╝╚══██╔══╝██╔════╝██║
██║     ██║   ██║██╔████╔██║██████╔╝██║     █████╗     ██║   █████╗  ██║
██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝     ██║   ██╔══╝  ╚═╝
╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ███████╗███████╗   ██║   ███████╗██╗
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝

UPGRADEEOF
else

echo "${RED}Service status is not active,its $status ${COLOR_RESET}"
fi
