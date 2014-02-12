#!/bin/bash
# Version 1.3
# for Ubuntu 13.10 (should be backwards compatable)

# This will ensure your project is in working order on a Ubuntu system
# The intent is to git pull then run this
# If on dev you need to edit /etc/hosts

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
cd ../sql
echo "Root Database Password:"
mysql -h localhost -u root -p < ../sql/config.sql

#Install Database
cd $scriptDir
bash update_db.bash

#Apache
cd ../apache
apacheDir=${PWD}
cd /etc/apache2/sites-available
rm -f $domainName
ln -s $apacheDir/$domainName $domainName.conf
a2ensite $domainName.conf
service apache2 reload
cd $scriptDir #back to start

#Permissions
cd ../
chown -R www-data:www-data public/
cd $scriptDir #back to start

#Done
echo "All done your site ($domainName) should be up now, just edit /etc/hosts for local development."