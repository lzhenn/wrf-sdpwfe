#!/bin/sh
LID=`date +%Y%m%d`
git add *.py
git add *.sh
git add ncl
git add fig
git commit -m "$LID"
git push origin master

