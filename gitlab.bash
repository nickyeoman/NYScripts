#!/bin/bash
# Install gitlab from fresh ubuntu 12.04
# v1.1
# Last Updated: Aug 4, 2012
# Documentation: 
# http://www.nickyeoman.com/blog/system-administration/180-install-gitlab-on-ubuntu
#
# Changelog
# 1.1 added ngnix install

#step 1 - 3
sudo apt-get install curl sudo
curl https://raw.github.com/gitlabhq/gitlabhq/master/doc/debian_ubuntu.sh | sh

# STEP 4
sudo gem install charlock_holmes
sudo pip install pygments
sudo gem install bundler
cd /home/gitlab
sudo -H -u gitlab git clone -b stable git://github.com/gitlabhq/gitlabhq.git gitlab
cd gitlab
sudo -u gitlab mkdir tmp

# Rename config files
sudo -u gitlab cp config/gitlab.yml.example config/gitlab.yml

#sqlite
sudo -u gitlab cp config/database.yml.sqlite config/database.yml

#mysql
#sudo -u gitlab cp config/database.yml.example config/database.yml
# Change username/password of config/database.yml  to real one

#install gems
sudo -u gitlab -H bundle install --without development test --deployment

#setup db
sudo -u gitlab bundle exec rake gitlab:app:setup RAILS_ENV=production

#run check
sudo -u gitlab bundle exec rake gitlab:app:status RAILS_ENV=production

# STEP 5
# Server up As daemon
sudo -u gitlab bundle exec rails s -e production -d

# STEP 6
# Manually
sudo -u gitlab bundle exec rake environment resque:work QUEUE=* RAILS_ENV=production BACKGROUND=yes

# Gitlab start script
./resque.sh

sudo apt-get install nginx

cd /home/gitlab/gitlab
sudo -u gitlab cp config/unicorn.rb.orig config/unicorn.rb
sudo -u gitlab bundle exec unicorn_rails -c config/unicorn.rb -E production -D

#added by nick for easy access
wget https://raw.github.com/nickyeoman/NYScripts/master/nginx.conf
sudo mv  /etc/nginx/nginx.conf  /etc/nginx/nginx.conf.bak
sudo mv nginx.conf /etc/nginx/nginx.conf
sudo chown root:root /etc/nginx/nginx.conf
sudo sudo chmod 644 /etc/nginx/nginx.conf

#restart
/etc/init.d/nginx restart

#pull one more file
wget https://raw.github.com/nickyeoman/NYScripts/master/nginx.init
sudo chown root:root /etc/nginx/nginx.init
sudo sudo chmod 755 /etc/nginx/nginx.init
sudo mv nginx.init /etc/init.d/gitlab

#gitlab autostart
sudo update-rc.d gitlab defaults

#gitlab restart
sudo /etc/init.d/gitlab restart