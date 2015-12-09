#!/bin/bash
#
#
# Author: Benjamin Rich
# Created: 2/29/2012
# Description: 
# Utility script that accepts three parameters: Ip address, 
# runtime in minutes & outputfile
# The script will ping this host 1 time every minute until the 
# runtime has been met. All output will log to the file specified
#
###############################################################

#Variables# 
#####################
host=$1
counter=$2
logfile=$3
#end Variables
#####################

display_usage() {
        echo "This script must be run with super-user privileges."
        echo "This script requires 3 parameters"
        echo "IP address, time to run in minutes and output file"
        echo -e "\nUsage:\n$0 [192.168.200.12 20 /tmp/pingOutput.txt] \n"
        }

# if less than three arguments supplied, display usage 
	if [  $# -lt 3 ] 
	then 
		display_usage
		exit 0
	fi 
 
# check whether user had supplied -h or --help . If yes display usage 
	if [[ ( $# == "--help") ||  $# == "-h" ]] 
	then 
		display_usage
		exit 0
	fi 
 
# display usage if the script is not run as root user 
	if [[ $USER != "root" ]]; then 
		echo "This script must be run as root!" 
		exit 0
	fi 

	echo -e "\n -- pingTool started at `date` --\n" >> $logfile
while [ $counter -gt 0 ] ; do
	capture=`/bin/ping -c1 $host | grep time=` 
        echo -e "`date` -- $capture\n"  >> $logfile
        sleep 30
        counter=$(( $counter - 1 ))
        echo "pingTool will run $counter more times"
done
