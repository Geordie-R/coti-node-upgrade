#!/bin/bash

# ██████╗ ██████╗ ████████╗██╗    ███╗   ██╗ ██████╗ ██████╗ ███████╗    ██╗   ██╗██████╗  ██████╗ ██████╗  █████╗ ██████╗ ███████╗
#██╔════╝██╔═══██╗╚══██╔══╝██║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝    ██║   ██║██╔══██╗██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔════╝
#██║     ██║   ██║   ██║   ██║    ██╔██╗ ██║██║   ██║██║  ██║█████╗      ██║   ██║██████╔╝██║  ███╗██████╔╝███████║██║  ██║█████╗
#██║     ██║   ██║   ██║   ██║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝      ██║   ██║██╔═══╝ ██║   ██║██╔══██╗██╔══██║██║  ██║██╔══╝
#╚██████╗╚██████╔╝   ██║   ██║    ██║ ╚████║╚██████╔╝██████╔╝███████╗    ╚██████╔╝██║     ╚██████╔╝██║  ██║██║  ██║██████╔╝███████╗
# ╚═════╝ ╚═════╝    ╚═╝   ╚═╝    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 ######### Unofficial upgrade script by GeordieR ##########


#Make sure running as the root user
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Parameters
filename="/etc/systemd/system/cnode.service"

#Install JQ which makes it easy to interpret JSON
apt-get update -y
apt-get install -y jq

cd /home/coti/coti-fullnode/

#Lets check if we actually need to git pull
changed=0
git remote update && git status -uno | grep -q 'Your branch is behind' && changed=1
if [ $changed = 1 ]; then
    git pull
    mvn initialize && mvn clean compile && mvn -Dmaven.test.skip=true package
else
    echo "Up-to-date. No git pull is needed"
fi

#Now we will go on to check the cnode.service file and update it if necessary

#new_version_tar=$(curl -s https://api.github.com/repos/coti-io/coti-node/releases/latest | jq ".tarball_url")
new_version_tag=$(curl -s https://api.github.com/repos/coti-io/coti-node/releases/latest | jq ".tag_name")

#Remove the front and end double quote
new_version_tag=${new_version_tag#"\""}
new_version_tag=${new_version_tag%"\""}


new_jar_name="fullnode-$new_version_tag.RELEASE.jar"

#Get full cnode.service inside a variable
cnode_file=$(<$filename)
#Get everything after the phrase below
after_fullnode=${cnode_file#*"/coti-fullnode/fullnode/target/"}
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
  echo "You have the same version: $new_jar_name that is listed in the cnode.service file compared to github. No changes needed"
echo "Process complete"
fi
