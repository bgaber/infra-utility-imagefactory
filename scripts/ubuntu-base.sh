#!/bin/bash 
set -x 
 
echo "Running Ubuntu Base Setup Script" 
 
sudo apt update 
# sudo apt install snmpd unzip
sudo apt install unzip
sudo snap install net-snmp
mkdir /tmp/buildfiles 
 
echo "Finished with Ubuntu Base Setup Script" 
