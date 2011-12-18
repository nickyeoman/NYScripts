#!/bin/bash
# Version 1.1

#this will ensure your project is in working order.  
# Just Git pull then run this
# Then if you require edit /etc/hosts
# All done

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
echo "Database Password:"
mysql -h localhost -u root -p < ../sql/config.sql

#Install Database
cd $scriptDir
bash update_db.bash

#Apache
cd ../apache
apacheDir=${PWD}
cd /etc/apache2/sites-available
rm -f $domainName
ln -s $apacheDir/$domainName
a2ensite $domainName
service apache2 reload
cd $scriptDir #back to start

#Permissions
cd ../
chown -R www-data:www-data html/
cd $scriptDir #back to start

#Done
echo "All done your site ($domainName) should be up now, just edit /etc/hosts for local development."