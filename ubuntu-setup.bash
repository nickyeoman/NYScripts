#!/bin/bash
# Install script for a clean install of Ubuntu 11.10
# v3.2
# Feb 10 2012
# NickYeoman.com

#vars
mytype='server'
#mytype='desktop'
#mytype='xubuntu'

#check to ensure root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 11
fi

#####################################
#	APT SECTION
#####################################

#For 11.04 on MT, but good to match systems
apt-get -y install language-pack-en-base

# Update
apt-get -y update

# Install Lamp
apt-get -y install lamp-server^ 
apt-get -y install php5-imagick php5-gd php5-cli

# Install Open SSH
#apt-get -y install openssh-server openssh-client #usually done for you already

# Development tools
apt-get -y install subversion nmap git-core htop p7zip-full

#magento
apt-get -y install curl php5-curl php5-mcrypt php5-mhash php5-dev php-pear 

#email 
apt-get -y install sendmail 

#####################################
#	Apache SECTION
#####################################

#enable mod-rewrite (html5boilerplate compatible)
a2enmod setenvif headers deflate filter expires rewrite
/etc/init.d/apache2 restart


#####################################
#	Server SECTION
#####################################
# My Personal Preferences for a desktop install
if [ "$my_type" = "server" ]; then
	# Everything on a server is on develpment machine too
	echo "server"
fi


#####################################
#	Desktop SECTION
#####################################
# My Personal Preferences for a desktop install
if [ "$my_type" = "desktop" ]; then
	apt-get -y install scite mysql-query-browser phpmyadmin k3b krename vlc picard

fi

#####################################
#	xubuntu SECTION
#####################################
# My Personal Preferences for a desktop install
if [ "$my_type" = "xubuntu" ]; then

	#this part mirrors desktop (but with heavy apps removed)
	apt-get -y install scite phpmyadmin 

	#just for xubuntu
	apt-get -y install system-config-samba gvfs-backends chromium-browser libreoffice
fi 

#####################################
#	Done
#####################################

#Clean things up
apt-get -y upgrade
apt-get autoclean
apt-get clean

more <<EOT 
*****************
All DONE!
*****************
EOT

