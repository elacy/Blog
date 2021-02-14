---
title: Diagnosing Overload
layout: post
categories:
  - Technology
tags:
  - SRE
---

As we create more microservices, maintaining resilience becomes more about quickly diagnosing overload. The ability to do so can save companies millions of dollars a year in hardware costs for services that would otherwise have to be overscaled to ensure availability. As someone who has been involved in diagnosing complicated overload scenarios, this is how I think about overload. All of my opinions are my own, not anyone else's.<!-- more -->

My golden rule with all outages is that there is never just one cause, but diagnosis is like poetry is never finsihed, only abandoned. What I mean by this is that even if the service got more traffic than expected usually the way it breaks is sub optimal, did your rate limiting per IP kick in as expected, did your on host load shedding work, how was the traffic priotised should be as much a part of your analysis as the prediction mechanism for capacity requirements. However if your service is sufficiently complicated you can investigate indefinitely.

The way you address this problem is through automation and the rest of this article is going to explain what your automation is going to look for. I'm going to assume for the purposes of this article that have been really good at recording a lot of metrics for your services and there is a standardised way at your company of collecting and storing these metrics/logs.

First question is when the overload happened, if you have an alarm you can identify that but even better is if you can identify when throughput stopped increasing, that's your breaking point, you want to know how you got there. You can find that by looking at when the load was being shed, your queues started filling or your SLAs were breached, whichever happened first. Next thing is to identify at the breaking point which resources constricted the successful request/s at breaking point. The common offenders are host resources (CPU/Disk/Memory) and service latency increasing.

Whatever the resource that constricted your request handling you want to try and identify if right before the event, requests were taking up more of that resource than they normally would, you want to split this search by operation, I would also recommend looking at the presense or absense of code timers for this although that can be lot harder it is nice to hand the developer the code block to investigate. With service latency you want to compare the average latency at normal and impacted (do not sum time that will increase/decrease with request count), if you can't spot the same service latency on the server side check your math and with networking for that route. With host resources you want to have a record of the CPU/Memory/Disk operations taken up by each request, you'll also want to account for hyperthreading, context switches in how you record that.

Split the requests by operation, was there an increase in any operation, if you calculate the increase against the resources used would that have produced an overload under normal circumstances? If yes then you need to deep dive into that traffic, where it came from and if you should have been able to predict it or do a better job of shedding it. There are many ways of rate limiting types of traffic and I won't get into that here but your automation should be able to pull any traffic information provided to it by the entry point for an ingress. 

Last piece is, did the requests by operation increase in proportion to the errors being produced by your system If so then this can indicate a retry storm and you need to consider this as part of your load shedding mechanisms and discuss retry strategies with your clients.

I believe that should tell you enough to take the next step in your investigation and if you can automate that it will improve your efficiency and resilience as recurring problems won't linger in your ticket queue.