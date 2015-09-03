#!/bin/sh
# set network interface to 100MB/FD
ETHTOOL="/usr/sbin/ethtool"
DEV="eth0"
SPEED="100 duplex full"
case "$1" in
start)
echo -n "Setting eth0 speed 100 duplex full...";
$ETHTOOL -s $DEV speed $SPEED;
echo " done.";;
stop)
;;
esac
exit 0
