#!/bin/bash
#
# Define Variables

SRMHOST=OFFLINE
SRMHOST=`hagrp -state srmGroup | grep 'ONLINE' | awk  '{ print $3 }'`

if [ -z "$SRMHOST" ]; then
	echo SRM is not running.  Cannot continue
	exit -1
fi

#
# Update local.conf to disable Policy Manager
#
disablePMconfig="ssh root@settingsserver sed -i 's/srm\.resourceManager=.*$/srm.resourceManager=InternalResourceManager,IPTVResourceManager/g' /usr/local/openstream/localconf/local.conf; sed -i 's/srm\.ipresourcemanager.*$/srm\.ipresourcemanager=IPTVResourceManager/g' /usr/local/openstream/localconf/local.conf"
#
# Update local.conf to disable Policy Manager
enablePMconfig="ssh root@settingsserver sed -i 's/srm\.resourceManager=.*$/srm.resourceManager=InternalResourceManager,IPTVResourceManager,VerizonResourceManager/g' /usr/local/openstream/localconf/local.conf; sed -i 's/srm\.ipresourcemanager.*$/srm\.ipresourcemanager=VerizonResourceManager/g' /usr/local/openstream/localconf/local.conf"
#
# Update SRM database to disable Policy Manager
disablePMdb="scp disablePMdb.ksh root@bmsdb:/tmp"
# Execute disablePMdb
edisablePMdb="ssh root@bmsdb su - oracle  '/tmp/disablePMdb.ksh'"
# Update SRM  database to enable Policy Manager
enablePMdb="scp enablePMdb.ksh root@bmsdb:/tmp"
# Execute enablePMdb
eenablePMdb="ssh root@bmsdb su - oracle  '/tmp/enablePMdb.ksh'"
# Shutdown SRM
srmdown="hares -offline srm -sys $SRMHOST"
# Startup SRM
srmup="hares -online srm -sys $SRMHOST"
# Reload SettingsServer
reloadSS="ssh root@settingsserver /usr/local/openstream/components/SettingsServer/scripts/reloadsettings"

# Log to the Centeralloger what the user did
logmessage="/usr/local/openstream/bin/logmessage Verizon_Service_Continuation INFO"
#


# It takes several seconds to shut down the SRM.  This loop validates it
# is down.  If we don't wait, the startup script runs before the SRM actually shuts down
# and the 'is running' check in the script, detects that the SRM is still running
# and consequently exits without doing anything

validateDown() {
	onlineCount=`hagrp -state srmGroup | grep 'ONLINE' | wc -l`
	echo $onlineCount
	while [ $onlineCount != 0 ]
	do
		sleep 1
		onlineCount=`hares -state srm | grep 'ONLINE' | wc -l`
		echo Waiting for SRM to stop
	done
}

while true
do 

clear # Clear the screen.

PS3="Choose (1-3) :"

echo "Choose from the list below, to enable or disable the Policy Manager"

select number in Disable_PolicyManager Enable_PolicyManager Exit
do 
	break
done

echo "You chose '$number'."

if [ "$number" = "" ]; then 
	echo "Invalid Entry."
	exit 1
fi


if [ "$number" = "Disable_PolicyManager" ]; then 
	$disablePMconfig
	$reloadSS
	$srmdown
	validateDown
	$disablePMdb
	$edisablePMdb
	$srmup
	$logmessage  PolicyManager Disabled by User
fi


if [ "$number" = "Enable_PolicyManager" ]; then 
	$enablePMconfig
	$reloadSS
	$srmdown
	validateDown
	$enablePMdb
	$eenablePMdb
	$srmup
	$logmessage PolicyManager Enabled by User
fi

if [ "$number" = "Exit" ]; then 
	$logmessage User exited system
    break
fi 

done
