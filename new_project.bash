#!/bin/bash
# Build Project Directories
# v2.0 (beta)
# Last Updated: Dec 25, 2011
# Documentation: 
# http://www.nickyeoman.com/blog/system-administration/18-project-directory-setup

# REQUIREMENTS
# 1 - PHP
# 2 - SVN
# 3 - GIT
# 4 - Unzip
# Install the above on ubuntu/debian:
# sudo apt-get install php-cli git-core svn unzip

# Vars
projectDir=/git
salt=XXXxxxXXX #change this if you want recoverable passwords

#Project Domain
if [ -z "$1" ]; then
  echo -n "What is the main domain name?"
  read domain
else
  domain=$1
fi

# Create Directories
cd $projectDir

#TODO: check for domain then error if exists
mkdir $domain
cd $projectDir/$domain
mkdir public lib core-edits scripts sql bind apache 

cd $projectDir/$domain

# Grab Nick Yeoman's scripts
cd scripts
wget https://raw.github.com/nickyeoman/NYScripts/master/config.sh
wget https://raw.github.com/nickyeoman/NYScripts/master/database.bash

cd $projectDir/$domain

#Pull CMSes
cd lib

#joomla
#find latest here: http://www.joomla.org/download.html
svn export --force --username anonymous --password "" http://joomlacode.org/svn/joomla/development/tags/1.7.x/1.7.3/ joomla

#wordpress
#find latest here: http://wordpress.org/download/
# wget http://wordpress.org/latest.zip
svn export http://core.svn.wordpress.org/tags/3.3 wordpress

#Drupal
# find latest here: http://drupal.org/download
#TODO: svn? git? anything better than wget?
wget http://ftp.drupal.org/files/projects/drupal-7.10.tar.gz
tar -xzf drupal-7.10.tar.gz
rm *.gz
mv drupal-7.10 drupal

#open cart
# latest: http://www.opencart.com/index.php?route=download/download
wget http://opencart.googlecode.com/files/opencart_v1.5.1.3.1.zip
unzip opencart_v1.5.1.3.1.zip
rm -rf *.zip *.txt
mv upload opencart

# media wiki
wget http://download.wikimedia.org/mediawiki/1.18/mediawiki-1.18.0.tar.gz
tar -xzf mediawiki-1.18.0.tar.gz
rm *.gz
mv mediawiki-1.18.0 mediawiki

# Piwik
wget http://piwik.org/latest.zip
unzip latest.zip
rm *.zip *.html

#Atrium
# latest: openatrium.com/download
wget http://openatrium.com/sites/openatrium.com/files/atrium_releases/atrium-1-1.tgz
tar -xzf atrium-1-1.tgz
rm *.tgz
mv atrium-1.1 atrium

# Gallery 3
wget http://downloads.sourceforge.net/gallery/gallery-3.0.2.zip
unzip gallery-3.0.2.zip
rm *.zip

# Mantis
# latest: http://sourceforge.net/projects/mantisbt/files/mantis-stable/
wget http://downloads.sourceforge.net/project/mantisbt/mantis-stable/1.2.8/mantisbt-1.2.8.tar.gz
tar -xzf mantisbt-1.2.8.tar.gz
rm *.gz
mv mantisbt-1.2.8 mantis

#vanilla
#latest: https://github.com/vanillaforums/Garden/tags
wget https://github.com/vanillaforums/Garden/zipball/Vanilla_2.0.18.1
mv Vanilla_2.0.18.1 Vanilla_2.0.18.1.zip
unzip Vanilla_2.0.18.1.zip
rm *.zip
mv vanillaforums-Garden-0745734 vanilla

#codeigniter
wget https://github.com/EllisLab/CodeIgniter/tarball/v2.0.3
tar -xzf v2.0.3
mv EllisLab-CodeIgniter-8c9758c/ codeIgniter/
rm -rf v2.0.3

cd $projectDir/$domain

#Create DB script
cd sql
wget https://raw.github.com/nickyeoman/NYScripts/master/sha1.php
dbpass=`php sha1.php $domain $RANDOM $RANDOM` #change this to use $salt $salt want to be able to recover passwords (less secure)
#arr=$(echo $domain | tr "." "\n")
#dbname= ${arr[0]}
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