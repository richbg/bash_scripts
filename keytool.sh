#!/bin/sh

# Author: Benjamin Rich 
# Created: Feb 9, 2014
# Description:
# Java KeyStore Automation



if [ $(whoami) != "root" ]; then
          echo "Please run as root." >&2
            exit 1
fi
 
 
# Setup common environment variables
JDK_HOME=/usr/local/jdk1.7.0_17
PATH=${JDK_HOME}/bin:$PATH
 
#set -x

printf "KeyStore Automation Executing\n"

# Remove old keys
rm -f config/keystore.jks; rm -f  config/cacerts.jks
 
# Create keystore
keytool -genkey -keyalg RSA -keystore /opt/glassfish2/domains/OpenStreamBillingCS/config/keystore.jks \
-validity 365 -dname "cn=billing, ou=Sample Location, o=Sample, c=US" -alias s1as \
-storepass changeit -keypass changeit
 
# Import  RootCA Cert
keytool -keystore cacerts.jks -keyalg RSA -import -trustcacerts -alias rootcert -file RootCA.cer \
-storepass changeit -keypass changeit -noprompt


# Import  Lab CA Cert
keytool -keystore cacerts.jks -keyalg RSA -import -trustcacerts -alias labscert -file Labs_CA.cer \
-storepass changeit -keypass changeit -noprompt
