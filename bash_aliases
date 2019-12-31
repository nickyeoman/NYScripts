#!/bin/bash
# Global Bash Aliases
# Version: 4
# Last Updated: Dec. 31, 2019

################################################################################
# Start Aliases
################################################################################

# Fix Typos
alias whios='whois'

# Command line Weather
alias weather='curl http://wttr.in/summerland'

# Remove the temp file systems from df
alias ds='df -h | grep -v tmpfs | grep -v udev | grep -v docker | grep -v snap | grep -v loop'

# Remember all my rsync parameters for a backup to portable hard drive
alias backup='rsync -r -t -p -o -g -x -v --progress --delete -c -H -i -s /home/nickyeoman/saveme /media/nickyeoman/portabledrive'

# Socks5 connection to offshore node (then just change  your sock settings in firefox or qbittorrent)
alias socks='ssh -D 8123 -f -C -q -N offshore.nickyeoman.com && echo -n "SOCKS started on port 8123.  You can kill " && ps aux | grep 8123 | grep -v color | awk '"'"'{print $2}'"'"

# Some of these are built into ubuntu
alias ll='ls -lah'
alias l1='ls -1'
alias ls='ls --color=auto'

# up levels (up #_of_dir_up)
function cd_up() {
  cd $(printf "%0.0s../" $(seq 1 $1));
}
alias 'up'='cd_up'

#run updates on ubuntu
alias updates='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove && sudo apt-get clean && sudo apt-get autoclean && sudo apt autoclean'

# Don't need these when Ctrl+d works
alias quit='exit'
alias e='exit'

## TMUX

# Start a new tmux session or connect to the existing one
alias t='tmux a -t nix || tmux new -s nix'
alias tl='tmux list-sessions'

## GIT

alias gs='git status'
alias gpgp='git pull;git push;'
alias gc='git-cola'
alias gclean='git reset --hard HEAD; git clean -df'

# ubuntu version with kernel
alias version='lsb_release -a; uname -a'

################################################################################
# XFCE
################################################################################

#open a GUI window in current location
alias window='thunar .'
