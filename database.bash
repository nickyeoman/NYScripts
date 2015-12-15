#!/bin/bash
# database.bash
# Automates working with a database
# v2.1
# Last Updated Dec 1 2015
# Documentation: http://www.nickyeoman.com/blog/db/31-mysql-backup-restore
 
##
#  Set/Get Variables
##
tstamp=$(date +%s)  # Date, The "+%s" option to 'date' is GNU-specific.
 
#Dump or Update?
if [ -z "$1" ]; then
  echo -n "What do you want to do?([D]ump or [U]pdate)"
  read parm
else
  parm=$1
fi
 
# Database name
if [ -z "$2" ]; then
  echo -n "What database are you using?"
  read dbname
else
  dbname=$2
fi
 
#Database user
if [ -z "$3" ]; then
  echo -n "What database user are you using?"
  read dbuser
else
  dbuser=$3
fi
 
#database password
if [ -z "$4" ]; then
  echo -n "What database password are you using?"
  read dbpass
else
  dbpass=$4
fi
 
#database host (in case not local)
if [ -z "$5" ]; then
  echo -n "What is the database host? (usually localhost)"
  read dbhost
else
  dbhost=$5
fi
 
##
#  Got everything we need, let's begin
##
 
#Regardless of what we are doing, create a backup of the existing database.
# This is a life saver when you run an update instead of a dump or want to restore to a previous dump
# if your using git, just add sql/backup/ to .gitignore then your dumps will remain local
 
#check to see if dir exists
if test ! -d "../sql/backup"; then
  mkdir ../sql/backup #if not make the directory
fi
 
#dump the database incase we want to revert
mysqldump -h $dbhost -u $dbuser -p$dbpass $dbname > ../sql/backup/$tstamp.$dbname.sql
 
 
#Great, what are we actually doing?
 
#dump or update the db
if [ "$parm" = d ]; then 
  mysqldump -h $dbhost -u $dbuser -p$dbpass $dbname > ../sql/$dbname.sql  
elif [ "$parm" = u ]; then #update the db
  mysql -h $dbhost -u $dbuser -p$dbpass $dbname < ../sql/$dbname.sql
else
  echo "d or u options only! (lower case)" 
fi
 
#All Done