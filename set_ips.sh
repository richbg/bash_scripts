#!/bin/bash
# basic utility script to set hostnames to the machines 
# current IP address 

myipaddr=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
#f1=/home/staging/OpenStream-hosts

#echo $myipaddr

  for f1 in sample-hosts; do
  mv $f1 $f1.old
  sed "s/x.x.x.x/$myipaddr/g" $f1.old > $f1
  cat $f1 >> /etc/hosts
  done


