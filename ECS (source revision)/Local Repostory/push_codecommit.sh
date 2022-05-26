#!/bin/bash

REGION = ap-southeast-1
REPONAME = terraform # codecommit repo name

git clone https://git-codecommit.$REGION.amazonaws.com/v1/repos/$REPONAME

cd $REPONAME

git remote add terraform https://git-codecommit.$REGION.amazonaws.com/v1/repos/$REPONAME

scp ../App . && git cp ../buildspec.yml .
git add .
git commit -m "push source from Local ok"

git checkout -b main # remote branch is 'main'
git push terraform main
