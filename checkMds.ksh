#!/bin/ksh

VERSION="1.1"

TEXTONLY=""
ERRORFILE=/var/tmp/disk.error; export ERRORFILE
MESSAGES=/var/tmp/disk.out; export MESSAGES
SDSPATH=/usr/sbin
DISPLAY=localhost:0.0
export DISPLAY

function prtUsage
{
#-------------------------------------------------------------------------------#   Purpose:  Print script usage
#-------------------------------------------------------------------------------
echo "Usage: $1 [-vt]"
   echo
   echo " v = print script version and exit"
   echo " t = text only; does not display terminal on localhost"
   echo
   exit 1
}
#*******************************************************************************

# Process command line options
while getopts :vt var
do
   case $var in
    v)   echo "Script Name : ${0##*/}"
         echo "Version     : $VERSION"
         exit 0;;
    t)   TEXTONLY="TRUE";;
    ?)   echo
         prtUsage ${0##*/};;
   esac
done

clear

# Get rid of any old messages
rm $ERRORFILE $MESSAGES > /dev/null 2>&1

# Verify that the SDS package is installed before continuing
echo "RUNINFO: `hostname`@`date`"
modinfo | grep 'Meta disk' >/dev/null
if [ $? -eq 0 ];
then
echo "Checking metadevices for errors.  Please be patient..."
# Check for metadb errors
        dbtrouble=`metadb | tail +2 | \
           awk '{ fl = substr($0,1,20); if (fl ~ /[A-Z]/) print $0 }'`
        if [[ -n $dbtrouble ]]
        then
           echo ""   >>$ERRORFILE
           echo "SDS replica problem report for `date`"   >>$ERRORFILE
           echo ""   >>$ERRORFILE
           echo "Database replicas are not active:"     >>$ERRORFILE
           echo ""   >>$ERRORFILE
           metadb -i >>$ERRORFILE
           echo "" >>$ERRORFILE
        fi
# Check for metadevice errors
        metastat | sed -n -e '/^d[0-9]*:/{
N
/State: [^(Okay)]/p
}' >> $ERRORFILE


echo "Verifying submirrors are all attached; Please wait..."
# Slight pause, as history shows that if a tool seems to do nothing,
# user assumes that to be the case.
sleep 2

# Report Number of Errors by checking all mirror lines
# (those that contain "-m") and making sure that each matched line
# has at least two "dxx" devices included.
numErrors=`metastat -p | egrep -c -e '\-m d[0-9]+ 1$'`
if [ $numErrors -ne 0 ];
then
# We found a one-way mirror; determine which sub is missing...
# Report our findings and show 'em how to fix it
   echo "" >> $ERRORFILE
   echo "WARNING: Found $numErrors broken mirror(s)! Details below...\n" >> $ERRORFILE
   metastat -p | egrep '\-m d[0-9]+ 1$' | \
   /usr/xpg4/bin/awk '{
   fixNeed = $3
   if (match(fixNeed, /d1/)) sub(/d1/, "d2", fixNeed)
   else if (match(fixNeed, /d2/)) sub(/d2/, "d1", fixNeed)
   else if (match(fixNeed, /d51/)) sub(/d51/, "d52", fixneed)
   else if (match(fixNeed, /d52/)) sub(/d52/, "d51", fixneed)
   else if (match(fixNeed, /d61/)) sub(/d61/, "d62", fixneed)
   else if (match(fixNeed, /d62/)) sub(/d62/, "d61", fixneed)
   print $1 ": NEEDS ATTENTION!"
   print "   " $3 " is the only attached submirror..."
   print "   Run: " "\047" SDS"/metattach " $1 " " fixNeed "\047" " to attach submirror.\n"}' "SDS=$SDSPATH" >> $ERRORFILE
fi

   if [ -s $ERRORFILE ]; then
# If errors found setup the alert
      echo "********************************************************************************" > $MESSAGES
      echo "********************************************************************************" >> $MESSAGES
      echo "*******************************WARNING!*****************************************" >> $MESSAGES
      echo "************************META-DEVICE IN ERROR!***********************************" >> $MESSAGES
      echo "**************PLEASE REFER TO $ERRORFILE FOR DETAILS**************" >> $MESSAGES
      echo "********************************************************************************" >> $MESSAGES
      echo "********************************************************************************" >> $MESSAGES
# Write the alert to /var/adm/messages
      logger -p local0.crit -f $MESSAGES
      echo "" >> $MESSAGES
      echo "" >> $MESSAGES
      echo "" >> $MESSAGES
      echo "" >> $MESSAGES
      echo "HIT RETURN TO ACKNOWLEDGE THIS MESSAGE!" >> $MESSAGES
# Send the alert to the terminal
      if [[ -z $TEXTONLY ]];
      then
         /usr/openwin/bin/xterm -bg OrangeRed -T "DISK ERRORS" -n "DISK ERRORS" -e /usr/bin/more -w $MESSAGES
      else
         echo
         echo
         echo "****************************** WARNING! ******************************"  
         echo "************************* META-DEVICE ISSUES *************************"
         echo
         cat $ERRORFILE
         echo
         echo "Please paste this information in the ticket."
      exit 1   
      fi 
   else
      echo "No problems found. Please paste this information in the ticket."
      exit 0
   fi

else
    echo "DiskSuite Not Installed, cannot run script"
    exit 1
fi
#*******************************************************************************
