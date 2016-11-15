#!/bin/bash
# reference: https://github.com/gitlabhq/gitlabhq/blob/master/doc/api/issues.md

#set vars
projectid=fbot-admin%2Ffrostybot-administration
title="SETME Testing Checklist"
labels='labels='Project - SETME'
privateToken='SETME'

#--------Begin Description ----------#
description=$(cat <<EOF

## SAMPLE TITLE

SAMPLE CHECKLIST:

* [ ] ITEM 1


EOF
)
#----------End description-----------#

curl -X POST -H "PRIVATE-TOKEN: $privateToken" \
--data-urlencode "title=$title" \
--data-urlencode "description=$description" \
--data-urlencode "labels=$labels" \
https://gitlab.com/api/v3/projects/$projectid/issues
