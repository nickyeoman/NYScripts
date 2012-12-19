#!/bin/bash
# Build Project Directories
# v4.3
# Last Updated: Dec 2, 2012
# Documentation: 
# http://www.nickyeoman.com/blog/system-administration/18-project-directory-setup

#Use like this: bash new_project.bash domainName.com

# CHANGELOG for 4.0
# Modified to work with plesk on CentOS
# dropped the use of symlinks for increased compatibility 
# plesk has one click installs, so we are only installing Joomla now
# We still want to run git so we are running from git/public instead of default httpdocs

# REQUIREMENTS
# Ubuntu/debian:
# sudo apt-get install php-cli
# You also need an internet connection

##
# Variables
##
	projectDir=/git #full path to install directory
	salt=$RANDOM #Change this to something static for recoverable passwords
	db_prefix="admin_"
	
	#Project Domain
	if [ -z "$1" ]; then
	  echo -n "What is the domain name for this project? [DomainName]"
	  read domain
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
# Grab Nick Yeoman's scripts
##
	cd scripts
	wget https://raw.github.com/nickyeoman/NYScripts/master/database.bash
	wget https://raw.github.com/nickyeoman/NYScripts/master/config.sh
	cd $projectDir/$domain

##
#Create DB script
##
	cd sql
	wget https://raw.github.com/nickyeoman/NYScripts/master/sha1.php
	dbpass=`php sha1.php $domain $salt $salt` 
	dbname=`echo $db_prefix$domain | sed 's/\(.*\)\..*/\1/'`
	dbuser=`echo $dbname`
	rm sha1.php
	
#--------Begin here document-----------#
cat <<xFileconfigsqlx > config.sql
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
#----------End here document-----------#

##
# Create Apache config file (config.sh uses this)
##
	cd $projectDir/$domain/apache
#--------Begin here document-----------#	
cat <<xFileconfigshx > $domain
<VirtualHost *:80>
	ServerName $domain
	ServerAlias www.$domain *.$domain
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
	
	wget http://joomlacode.org/gf/download/frsrelease/17715/77262/Joomla_2.5.8-Stable-Full_Package.zip
	unzip -e Joomla_2.5.8-Stable-Full_Package.zip
	rm -rf *.zip
	cd $projectDir/$domain

##
# All Done
##

cat <<xtalkToMex

****************************************
Installation Finished
Your domain ($domain) is setup
Directory = $projectDir/$domain
Database name = $dbname
Database user = $dbuser
Databse password = $dbpass
(you can refer to config.sql for this info)

Notes: 
* Fix permissions
* git init
* You can now run config.sh on your debian based dev server (as root)
****************************************
xtalkToMex

exit
