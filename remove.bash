#!/bin/bash
# Version 1.0

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

#Ensure database user
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
rm -rf .git #(only need current files for backup)
sitedir=${PWD}
cd ..
7za a -t7z $domainName.7z $sitedir && rm -rf $sitedir

#Done
echo "All done your site ($domainName) is removed, you have to manually remove it from /etc/hosts if it exists"