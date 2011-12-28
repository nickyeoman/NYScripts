#!/bin/bash
# Build Project Directories
# v3.0
# Last Updated: Dec 28, 2011
# Documentation: 
# http://www.nickyeoman.com/blog/system-administration/18-project-directory-setup

# REQUIREMENTS
# Ubuntu/debian:
# sudo apt-get install php-cli git-core svn unzip
# You also need an internet connection

##
# Variables
##
	projectDir=/git #full path to install directory
	salt=$RANDOM #Change this to something static for recoverable passwords
	defaultInstall=joomla #lib directory to move to the public directory

	#Project Domain
	if [ -z "$1" ]; then
	  echo -n "What is the domain name for this project?"
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
	mkdir lib core-edits scripts sql bind apache 
	cd $projectDir/$domain

##
# Grab Nick Yeoman's scripts
##
	cd scripts
	wget https://raw.github.com/nickyeoman/NYScripts/master/config.sh
	wget https://raw.github.com/nickyeoman/NYScripts/master/database.bash
	cd $projectDir/$domain

##
#Create DB script
##
	cd sql
	wget https://raw.github.com/nickyeoman/NYScripts/master/sha1.php
	dbpass=`php sha1.php $domain $salt $salt` 
	dbname=`echo $domain | sed 's/\(.*\)\..*/\1/'`
	dbuser=`echo u$dbname`
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
	cd $projectDir/$domain

##
# Create sample symlink
##
	cd scripts
#--------Begin here document-----------#
cat <<xFileconfigshx > symlink.sh
# Sample symlinik.sh file
# NOTE: lib dirs will have to be renamed for this to work (remove version numbers from software)
cd ../public
ln -s ../lib/atrium collaboration
ln -s ../lib/drupal drupal
ln -s ../lib/gallery3 photos
ln -s ../lib/mantis bugs
ln -s ../lib/mediawiki wiki
ln -s ../lib/opencart shop
ln -s ../lib/piwik analytics
ln -s ../lib/vanilla forum
ln -s ../lib/wordpress wordpress

#Sample Core Edits
mv configuration.php ../core-edits
ln -s ../core-edits/configuration.php

mv htaccess.txt ../core-edits/htaccess
ln -s ../htaccess .htaccess

xFileconfigshx
#----------End here document-----------#
	cd $projectDir/$domain

##
# Create Apache config file (config.sh uses this)
##
	cd apache
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
	cd $projectDir/$domain

##
#Pull CMSes
##
	cd lib
	
	wget https://raw.github.com/nickyeoman/NYScripts/master/cms-latest.txt
	
	cat cms-latest.txt | while read line
	do
		wget $line
	done
	
	rm cms-latest.txt
	
	#extract tarballs
	for filename in *.tar.gz
	do
	  tar zxf $filename
	done
	
	rm *.tar.gz #done with tars
	
	#extract tarbombs
	for filename in *.tarbomb
	do
		folder=${filename%%.*}
		mkdir $folder
		mv $filename $folder/.
		cd $folder
		tar zxf $filename
		rm *.tarbomb
		cd ..
	done
	
	#extract zips
	for filename in *.zip
	do
	  unzip $filename
	done
	
	rm *.zip #done with zips
	
	#remove non directories
	rm *.txt *.html

	cd $projectDir/$domain

##
# Move default install to public
##
	mv lib/$defaultInstall public

##
# GIT
##
	git init
	git add *
	git commit -a -m"Used nick's new project script"

##
# All Done
##

echo <<xtalkToMex


****************************************
Installation Finished
Your domain ($domain) is setup
Directory               = $projectDir/$domain
Database name     = $dbname
Database user       = $dbuser
Databse password = $dbpass
(you can refer to config.sql for this info)

Notes: 
* Your symlink file won't work without renaming lib dirs
* You can now run config.sh to install to server (as root)
* It's recommended to remove any lib dirs your not using (for space)
****************************************

xtalkToMex