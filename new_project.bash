#!/bin/bash
# Build Project Directories
# v6.0
# Last Updated: Apr 28, 2013
# Documentation: 
# http://www.nickyeoman.com/blog/system-administration/18-project-directory-setup

#Use like this: bash new_project.bash domainName.com dbname dbuser dbpass

# REQUIREMENTS
# Joomla 2.5.11
# Ubuntu/debian:
# sudo apt-get install php-cli zenity
# You also need an internet connection (to pull from github)

##
# Variables
##
	projectDir=/git #full path to install directory
	salt=$RANDOM #Change this to something static for recoverable passwords
	sinstall=http://joomlacode.org/gf/download/frsrelease/18322/80354/Joomla_2.5.11-Stable-Full_Package.zip
	
#Project Domain
	if [ -z "$1" ]; then
	  #echo -n "What is the domain name for this project? [DomainName]"
	  domain=`zenity --entry --title="New Project Script" --text="What is the domain name for this project? [DomainName]"`
	else
	  domain=$1
	fi
	
##
# Create Directories
##
	cd $projectDir
	#TODO: check for domain then error if exists
	mkdir $domain
	cd $projectDir/$domain
	mkdir scripts sql apache

##
# Database info
##
	#db name
	if [ -z "$2" ]; then
		dbname=`echo $domain | sed 's/\(.*\)\..*/\1/'`
	else
		dbname=$2
	fi
	
	#db user
	if [ -z "$3" ]; then
		dbuser=`echo $dbname`
	else
		dbuser=$3
	fi
	
	#dbpass
	if [ -z "$4" ]; then
		cd sql
		wget https://raw.github.com/nickyeoman/NYScripts/master/sha1.php
		dbpass=`php sha1.php $domain $salt $salt` 
		rm sha1.php
		cd $projectDir
	else
		dbpass=$4
	fi

##
# Grab Nick Yeoman's scripts
##
	cd $projectDir/$domain/scripts
	wget https://raw.github.com/nickyeoman/NYScripts/master/database.bash
	wget https://raw.github.com/nickyeoman/NYScripts/master/config.bash
	cat <<xFiledumpx > dump_db.bash
./database.bash d $dbname $dbuser $dbpass localhost
xFiledumpx
	cat <<xFileupdatex > update_db.bash
./database.bash u $dbname $dbuser $dbpass localhost
xFileupdatex

	cd $projectDir/$domain

	
#--------Begin Config sql document-----------#
cat <<xFileconfigsqlx > $projectDir/$domain/sql/config.sql
-- Remove Existing Database
DROP DATABASE IF EXISTS $dbname;
-- Create database
CREATE DATABASE $dbname;
-- Make remove user (create one to suppress errors)
GRANT USAGE ON *.* TO '$dbuser'@'localhost';
-- Drop the user
DROP USER '$dbuser'@'localhost';
-- Create the correct user with correct password
GRANT ALL PRIVILEGES ON $dbname.* to '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
xFileconfigsqlx
#----------End document-----------#

##
# Create Apache config file (config.sh uses this)
##
	cd $projectDir/$domain/apache
	project=`echo $domain | sed 's/\(.*\)\..*/\1/'`
#--------Begin here document-----------#	
cat <<xFileconfigshx > $domain
<VirtualHost *:80>
	ServerName $domain
	ServerAlias www.$domain *.$domain $project.ny $project.fb
	DocumentRoot $projectDir/$domain/public/
	ServerAdmin webmaster@$domain
	
	<Directory $projectDir/$domain/public/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
	
	ErrorLog /var/log/apache2/error_$domain.log
</VirtualHost>

xFileconfigshx
#----------End here document-----------#
	
##
# Install Joomla to Public
##
	mkdir $projectDir/$domain/public
	cd $projectDir/$domain/public
	
	wget $sinstall
	unzip -e *.zip
	rm -rf *.zip
	cd $projectDir/$domain
	
## Permissions
	cd $projectDir/$domain/scripts
	chmod u+x *
	cd $projectDir/$domain
	
##
# All Done
##

cat <<xtalkToMex

****************************************
Installation Finished
Your domain ($domain) is setup

Notes: 
* Run config.bash to setup database
* Update .htaccess (php, non-www, redirects)
* Go to the web to run the web installer
* Install frosty apps
* git init and push
****************************************
xtalkToMex

exit
