#!/bin/bash 
set -x 
 
echo "Running Base Setup Script" 
 
sudo yum -y update 
#sudo yum -y install nano net-snmp net-snmp-utils ntp unzip
sudo yum -y install nano net-snmp net-snmp-utils sysstat bash-completion unzip
mkdir /tmp/buildfiles 
 
echo "Finished with Base Setup Script" 
