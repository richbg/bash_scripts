#!/bin/bash
#
#
# Author: Benjamin Rich
# Created: May 5, 2010
# Description: Fix uid & gid for osadmin to be unique

if [ $(whoami) != "root" ]
then
  echo "This script must be run as root."
  exit 1
fi

# Variables
old_uid=`id -u osadmin`
old_gid=`id -g osadmin`
new_uid='1100'
new_gid='1100'
user='osadmin'

#echo $old_uid
#echo $old_gid

# Update osadmin uid and gid to be unique
groupmod -g $new_gid $user
usermod -u $new_uid -g osadmin $user

# Update ownership for files and directories owned by osadmin 
echo "Updating osadmin permissions" 

find / -user $old_uid -print -exec chown -h $new_uid {} \;
find / -group $old_gid -print -exec chgrp $new_gid {} \;

echo "Process Complete"
