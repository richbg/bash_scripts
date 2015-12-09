#!/usr/bin/bash
#

# Author: Benjamin Rich
# Created: August 25, 2005
# Description:
# Utility to mount NFS Storage Array. 
#
# Define Variables
#
# Modify the mount variable to reflect site settings. 
Mount="/usr/sbin/mount 10.252.250.121:/jumpstart /mnt/tmp/"
# Modify the umount variable to reflect site settings.
Umount="/usr/sbin/umount /mnt/tmp"
logmessage="/usr/local/n2bb/bin/logmessage NFS INFO"
#

while true
do 

clear # Clear the screen.

PS3="Choose (1-3) :"

echo "Choose from the list below."

select number in Mount-NFS Unmount-NFS Exit
do 
	break
done

echo "You chose '$number'."

if [ "$number" = "" ]; then 
	echo "Invalid Entry."
	exit 1
fi


if [ "$number" = "Mount-NFS" ]; then 
	$Mount
	$logmessage  NFS Server mounted by User
fi


if [ "$number" = "Unmount-NFS" ]; then 
	$logmessage NFS Server Un-mounted by User
	$Umount
fi

if [ "$number" = "Exit" ]; then 
	$logmessage NFS User exited system
    break
fi 

done
