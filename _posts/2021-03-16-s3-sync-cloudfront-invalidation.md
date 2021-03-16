---
title: S3 Sync and Cloudfront Invalidation
layout: post
categories:
  - Technology
tags:
  - aws
  - cloudfront
  - s3
---

![](/assets/images/2021/03/16/s3-sync-cloudfront-invalidation/cloudfront_locations.png "Locations of Cloudfront's cache across the globe")

An annoying feature of cloudfront invalidations is that if you use `/*` as the invalidation path it only invalidates the root directory, not any sub directories. Also it's rather frustrating that I have to invalidate the entire cache just to update a few files, particularly if it's invalidating less frequently cached items. So I wrote a script to automate this. <!-- more -->


This assumes you are using Code Build to publish something to s3, if not then replace `$CODEBUILD_BUILD_ID` with your unique invalidation identifier.

```
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
```

This does the following:

- Syncs your s3 bucket to a temp directory
- Compares the differences between the final version and temp directory using rsync looking for files that exist in the s3 bucket but will need to be deleted or updated
- Adds the root path to the list every time because I wasn't bothered checking if index.html is in the list
- Constructs the JSON required for cache invalidation, you can see this documented [here](https://docs.aws.amazon.com/cli/latest/reference/cloudfront/create-invalidation.html#examples)
- Syncs the local dir with S3
- Sends Cloudfront the invalidation

If you are wondering why `AWS_PAGER=""` is there, for some reason I cannot understand create-invalidation requires user input after running unless you clear that variable, I picked that up [here](https://github.com/aws/aws-cli/issues/4973).