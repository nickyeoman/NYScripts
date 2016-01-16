#!/bin/bash

cd /git

#loop through directories
for d in */ ; do

	cd $d
	
	if ! git diff --quiet
	then
	    echo "$d has uncommited files"
	    git status -s
	    echo ""
	fi
    cd ..

done
