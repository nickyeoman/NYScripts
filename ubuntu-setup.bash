#!/bin/bash
# Install script for a clean install of Ubuntu 11.10
# v3.0
# Dec 17 2011
# NickYeoman.com

#vars
mytype='server'
#mytype='desktop'

#check to ensure root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 11
fi

#####################################
#	APT SECTION
#####################################

#For 11.04 on MT
apt-get -y install language-pack-en-base

# Update
apt-get -y update

# Install Lamp
apt-get -y install lamp-server^ 
apt-get -y install php5-imagick php5-gd php5-cli

# Install Open SSH
#apt-get -y install openssh-server openssh-client #usually done for you already

# Development tools
apt-get -y install subversion nmap git-core

#magento
apt-get -y install curl php5-curl php5-mcrypt php5-mhash php5-dev php-pear 

# My Personal Preferences for a desktop install
if [ "$my_type" = "desktop" ]; then
	apt-get -y install scite mysql-query-browser phpmyadmin
	apt-get -y install k3b amarok krename vlc picard thunderbird pidgin
fi

#email 
apt-get -y install sendmail 

#Clean things up
apt-get -y upgrade
apt-get autoclean
apt-get clean


#####################################
#	Apache SECTION
#####################################

#enable mod-rewrite (html5boilerplate compatible)
a2enmod setenvif headers deflate filter expires rewrite
/etc/init.d/apache2 restart

#####################################
#	Done
#####################################
more <<EOT 
*****************
All DONE!
*****************
EOT

