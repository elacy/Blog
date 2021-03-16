#!/bin/bash
set -e
echo "Syncing current site to temp directory"
aws s3 sync $S3_PATH /tmp/site --delete
echo "Comparing for differences"
rsync -avnci --delete _site/ /tmp/site/ | grep '^>fc\|^*deleting' | awk '{print "/"$2}' > /tmp/diff
echo "/" >> /tmp/diff
lines=`cat /tmp/diff | wc -l | sed 's/^ *//g'`
echo "Building invalidation payload"
jq --raw-input --slurp 'sub("\n$";"") | split("\n")' /tmp/diff | jq '{"Paths": {"Quantity": '$lines', "Items": .}, "CallerReference": "'$CODEBUILD_BUILD_ID'"}' > /tmp/invalidation.json
echo "Syncing with S3"
aws s3 sync _site/ $S3_PATH --delete
echo "Creating cache invalidation"
AWS_PAGER="" aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --invalidation-batch file:///tmp/invalidation.json