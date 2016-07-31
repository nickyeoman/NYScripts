#!/bin/bash
# Build Project Directories
# v16.2
# Last Updated: Apr. 12, 2016
# Documentation:
# https://www.nickyeoman.com/blog/workflow/18-creating-a-new-web-project-directory
# Gist:
# https://gist.github.com/760ca8af6b868be3301d.git
# GitHub:
# https://github.com/nickyeoman/NYScripts/blob/master/newProject.bash

# Use like this: bash newProject.bash domainName.com dbname dbuser dbpass

# REQUIREMENTS
# Joomla 3.5.1
# Ubuntu/debian:
# You need an internet connection (to pull from github)

##
# Variables
##
	projectDir=/git #full path to install directory
	salt=$RANDOM
	sinstall=https://github.com/joomla/joomla-cms/releases/download/3.5.1/Joomla_3.5.1-Stable-Full_Package.zip
	htacc=https://raw.githubusercontent.com/nickyeoman/NYScripts/master/htaccess.txt
	humans=https://raw.githubusercontent.com/nickyeoman/NYScripts/master/humans.txt
	robots=https://raw.githubusercontent.com/nickyeoman/NYScripts/master/robots.txt
	wmtools=https://raw.githubusercontent.com/nickyeoman/NYScripts/master/google5e5f3b5cfa769687.html
	linuxusername=nick
	linuxgroup=nick

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

	#check if dir exists
	directory=$projectDir/$domain
	if [ -d "$directory" ]; then
		echo "$directory already exists"
		exit 0
	fi

	#create folders
	mkdir $domain
	cd $projectDir/$domain
	mkdir scripts sql apache docs
	mkdir sql/backup

##
# Database info
##
	#db name
	if [ -z "$2" ]; then
		notld=`echo $domain | sed 's/\(.*\)\..*/\1/'` #no tld
		#make it pretty for plesk (optional)
		len=${#notld}
		if [ $len -gt 7 ]; then
			firstpart=`echo $notld | cut -c1-7`
			dbname=${firstpart}_joomla
		else
			dbname=${notld}_joomla

		fi
	else
		dbname=$2
	fi

	#db user
	if [ -z "$3" ]; then
		dbuser=`echo $dbname`
		#make it pretty for plesk (optional)
		len=${#notld}
		if [ $len -gt 5 ]; then
			firstpart=`echo "$dbuser" | cut -c1-5`
			dbuser=${firstpart}_joomla
		else
			dbuser=${notld}_joomla
		fi
	else
		dbuser=$3
	fi

	#dbpass
	if [ -z "$4" ]; then
		cd sql
		wget https://raw.github.com/nickyeoman/NYScripts/master/sha1.php
		dbpass=`php sha1.php $domain $salt $salt`
		dbpass=`echo "$dbpass" | cut -c1-16`
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
	wget https://raw.github.com/nickyeoman/NYScripts/master/remove.bash
	cat <<xFiledumpx > dump_db.bash
./database.bash d $dbname $dbuser $dbpass localhost
xFiledumpx
	cat <<xFileupdatex > update_db.bash
./database.bash u $dbname $dbuser $dbpass localhost
xFileupdatex

	cd $projectDir/$domain


#--------Begin Config sql document-----------#
cat <<xFileconfigsqlx > $projectDir/$domain/sql/config.sql
-- DB Name: $dbname
-- DB User: $dbuser
-- DB Pass: $dbpass

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

#--------Begin Config sql document-----------#
cat <<xFileremovesqlx > $projectDir/$domain/sql/remove.sql
-- Remove Existing Database
DROP DATABASE IF EXISTS $dbname;
-- Drop the user
DROP USER '$dbuser'@'localhost';
xFileremovesqlx
#----------End document-----------#

##
# Create Apache config file (config.sh uses this)
##
	cd $projectDir/$domain/apache
	project=`echo $domain | sed 's/\(.*\)\..*/\1/'`
#--------Begin here document-----------#
cat <<xFileconfigshx > $domain.conf
<VirtualHost *:80>
	ServerName $domain
	ServerAlias www.$domain *.$domain $project.ny $project.fb
	DocumentRoot $projectDir/$domain/public/
	ServerAdmin social@frostybot.com

	<Directory $projectDir/$domain/public/>
		Options +Indexes +FollowSymLinks -MultiViews
		AllowOverride All
		Require all granted
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


##
# Pull stuff from Frostybot.com
##
cd $projectDir/$domain/public

wget $humans	#humans.txt
wget $robots #robots.txt
wget $wmtools #Google webmaster tools
wget $htacc --output-document=.htaccess #get custom google htaccess

# Pump in db info to installer
cd installation/view/database/tmpl
sed -i "s/getInput('db_user')/getInput('db_user',null,'$dbuser')/g" default.php
sed -i "s/getInput('db_pass')/getInput('db_pass',null,'$dbpass')/g" default.php
sed -i "s/getInput('db_name')/getInput('db_name',null,'$dbname')/g" default.php

cd $projectDir/$domain

##
# README file for gitlab
##
cat <<xFilereadmex > README.md
# Info for $domain

# INSTALLATION

## First Time
* [ ] Have your root system and mysql username and password ready
* [ ] Run 'sudo bash config.bash' to install the database
* [ ] Configure your DNS or /etc/hosts file
* [ ] Go to the domain and run the Joomla web installer
* [ ] Dump the database 'sudo bash dump_db.bash'
* [ ] Create the git repo 'git init'
* [ ] Add your remote
* [ ] Push to remote

## From repo

* git clone url name
* cd scripts && sudo bash config.bash

#Billing Information

Monthly Maintenance plan for the rate of *amount* until *date*.

## Contact Information

Name:
Email:
Phone:
Contact Page:

# Domain Name

Domain Name is registered at:
With the username:

# DNS

Name Servers are pointed to: Cloudflare

# Hosting

Currently on server: lamp.frostybot.com

# Email

MX record currently points to: Fbemail.net

# Website

Currently running: Joomla

## SMTP

* SMTP Sends through sendgrid with username

## Joomla Core Edits

No core edits at this Time

## Joomla plugins installed

* osmap
* frostyform
* FJT Template
* bruteforce
* rokpad
* rokboost

## Databse config

* DB Name: $dbname
* DB User: $dbuser
* DB Pass: $dbpass

xFilereadmex
#----------End here document-----------#

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

Go to $projectDir/$domain and open
README.md for more info
****************************************
xtalkToMex

exit
