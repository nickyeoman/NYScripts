#!/bin/bash
# Version 1.0
# Requires 7za installed: sudo apt-get install p7zip-full
# backup project

#user variables
backDir=./ #backup directory absolute path with postfixed slash

#Must be run from scripts dir!
scriptDir=${PWD}
#Get the domain name of the site we are working on
cd ..
domainName=${PWD##*/}

cd $scriptDir #back to start

#Ensure database backedup
bash dump_db.bash #backup

#backup
cd ..
sitedir=${PWD}
cd ..
tstamp=$(date +"%Y%m%d")  # Date, in format YYYYmmdd
7za a -t7z $backDir$tstamp-$domainName.7z $sitedir

#Done
echo "Finished. Your website ($domainName) is backed up."