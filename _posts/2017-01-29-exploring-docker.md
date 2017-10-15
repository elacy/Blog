---
title: Exploring Docker
layout: post
categories:
  - Technology
tags:
  - Docker
  - Asp.net
---

A friend of mine put me onto docker a few weeks ago and since then I’ve become rather obsessed with all things docker. I’ve gone from tinkering around with containers to recommending my company look into a strategy that will fully containerize our asp.net application.

Let me wind back a bit and explain why.

First of all a docker container is like a virtual machine except it shares the kernel with the host system so less overhead. Each docker instance is defined by a Dockerfile which inherits from another docker image and defines what makes that docker image unique.

For example, Wordpress docker file could inherit from nginx, which in turn could inherit from a Linux OS. How does that work? Well you run a command that looks something like `docker run -itd -morearguments someonepopular/wordpress`. That downloads the wordpress image, the ngnix image and any image that depends on, when all the images are downloaded it applies each image in a union file system to create a single container which starts up and starts wondering where your database is.

Why is that useful? For these reasons:

- No more conflicts between different versions of a dependency
- Each container has it’s own networks and IP addresses, so I can restrict access to my database to a limited number of containers
- Spinning up a new container once you’ve downloaded images is almost instantaneous
- You can restrict the resources available to each container
- There is a place called docker hub which has almost any application you can imagine dockerized ready to go in a single command
- It almost completely abstracts your bare metal machine without massive performance overhead
- There are already multiple competing orchestration frameworks for managing multiple physical machines with as many containers as you like

**Caveat** though, support on windows is still pretty early days, however Visual Studio 2017 comes with docker support allowing you to debug an asp.net web app inside a docker container. Now imagine being able to ramp up redis, rabbitmq, sql server docker images, then delete them all to start again as part of your development environment, imagine all the configuration for each of these dependencies being in source control and the same containers being used in your production environment. It’s not that far away.
