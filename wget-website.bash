#!/bin/bash
# Mirror A Website with Wget
# v1.0
# Last Updated: Apr. 1, 2015
# Documentation: 
# https://www.nickyeoman.com/blog/system-administration/202-mirror-a-website-with-wget

# Domain
if [ -z "$1" ]; then
  echo -n "What is the domain name that you want to mirror?" 
  read domain
else
  domain=$1
fi

# Save Locations
if [ -z "$2" ]; then
  location=/home/nick/working/
else
  location=$2
fi

wget --recursive --no-clobber --page-requisites --html-extension --convert-links --restrict-file-names=windows --domains $domain --no-parent $domain --directory-prefix $location