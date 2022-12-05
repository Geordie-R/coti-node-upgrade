#!/bin/bash
resetarg=$1


read -p "What is your ubuntu username for coti node? (if unsure write coti) : " user_name
config_file="/home/$user_name/coti-node/fullnode.properties"

function set_config_value(){
  #This replaces a key-pair value
  paramname=$(printf "%q" $1)
  paramvalue=$(printf "%q" $2)

  #echo $paramname
  #echo $paramvalue
  sed -i -E "s/^($paramname[[:blank:]]*=[[:blank:]]*).*/\1$paramvalue/" "$config_file"
}

#----------------------------------------------------------------------------------------------------#
# get_config_value: GLOBAL VALUE IS USED AS A GLOBAL VARIABLE TO RETURN THE RESULT                                     #
#----------------------------------------------------------------------------------------------------#

function get_config_value(){
  global_value=$(grep -v '^#' "$config_file" | grep "^$1=" | awk -F '=' '{print $2}')
if [ -z "$global_value" ]
  then
    return 1
  else
    return 0
  fi
}




get_config_value "reset.transactions"
reset="$global_value"

if [[ $reset == "" ]];
then
echo reset.transactions=true >> $config_file
else
set_config_value "reset.transactions" "$resetarg"
fi


get_config_value "reset.transactions"

echo "Reset transactions is now set to $global_value"
