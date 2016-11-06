#/bin/bash
#
#!/bin/bash
# database.bash
# Update SSL Certificate
# v1
# Last Updated Nov 5 2016
# Documentation: none yet

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../apache/ssl/apache.key -out ../apache/ssl/apache.crt
