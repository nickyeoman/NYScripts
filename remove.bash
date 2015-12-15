#!/bin/bash
# Version 2.0
# Requires 7za installed: sudo apt-get install p7zip-full
# removes a project

#check to ensure root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 11
fi

#Must be run from scripts dir!
scriptDir=${PWD}
#Get the domain name of the site we are working on
cd ..
domainName=${PWD##*/}

cd $scriptDir #back to start

#Ensure database backedup
bash dump_db.bash #backup
cd ../sql
echo "Root Database Password:"
mysql -h localhost -u root -p < ../sql/remove.sql

#Apache
cd /etc/apache2/sites-available
rm -f $domainName.conf
a2dissite $domainName.conf
service apache2 reload
cd $scriptDir #back to start

#backup
cd ..
sitedir=${PWD}
cd ..
7za a -t7z $domainName.7z $sitedir && rm -rf $sitedir

#Done
echo "Finished. Your website ($domainName) is removed. But you still need to:"
echo "1. Move the 7z backup file somewhere"
echo "2. Remove the /etc/hosts entry"
echo "3. Remove any log files"