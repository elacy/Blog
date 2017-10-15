---
title: Backing up Solr from a Linux to Windows
layout: post
categories:
  - Technology
tags:
  - Backup
  - Solr
---
[<img class="aligncenter size-full wp-image-132 img-thumbnail img-responsive" title="solr" src="/assets/images/2012/12/solr.png" alt="" width="283" height="156" />][1]

I've come across a problem with backing up Solr. Before 3.6 if you try to back it up you will have to unload the core or stop the server that hosts Solr before backing up the files.

Even with 3.6 and later, while the backup feature does exist which allows you to backup using the replication handler to get a snapshot created in a directory of your choice (location parameter) the snap shot is not differential so it will just copy your entire index and there is no way to tell if the backup has completed successfully or is in the middle of backing up. It creates a new lock file in the source code but never obtains it, so a lock file is never created.

Plus you would have to write your own retention script as the one supplied only handles “number of backups to retain” which isn't great if you have a 200GB Solr index and you want to hold onto the backups for a week and if you have one central backup server then it would have to ship the backups to that server, which can be a little awkward if, as is in my case, your backup server is running windows.

Ideally you would have an application that calls the replication handler and asks it for the current index just like a Solr slave. You could do differential backups, resume when the connection falls over, put it in a directory of your choice and even back up all the configuration files all in the same simple system.

I've written a c# program for this in work, which means I can't release the source, but perhaps it might be better to write in Java anyway.

Backup is important and I think it's worth addressing, especially since a lot of Solr indexes can take a lot of time to recreate.

 [1]: /assets/images/2012/12/solr.png