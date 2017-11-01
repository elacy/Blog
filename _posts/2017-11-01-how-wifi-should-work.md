---
title: How wifi authentication should work
layout: post
categories:
  - Technology
tags:
  - Wifi
  - WPA
---

Why is it that connecting to a WIFI involves sharing a key to aid synchronous encryption, often printed on a piece of paper which is put on display in public view?

What are the threat models when it comes with wireless networking and how does this solution rate when we look at the dangers associated with communication?<!-- more -->

The big threats to a network like this are packet sniffing which would allow an attacker to read your network traffic and an attacker gaining access to resources they wouldn't otherwise have access. This are really serious breaches that could have significant impact on both network owners and users!

This is especially worrying when, with this kind of encryption you have an illusion that there is actually any protection, when fundamentally any static password is a target that will always be possible to break. Perhaps it may take a 100 years to brute force it with what's currently available but what about tomorrow? How long is your security going to remain in place and what will change in terms of the security between now and then. 

Another point, how secure are all the devices that connect to the network? If they contain the master password for your entire wifi, what guarantee is there that they will not leak your password? There isn't any!

So what's the solution? Well we can use existing technologies to improve it. We have the WPA Enterprise system that gives each different device that connects a different password, we can use captive portals to allow people to authenticate individually.

### Authentication

Which begs the question, how do I authenticate? Well how about facebook?

Every person I have ever let onto my wifi has been a friend on my facebook. Why can't I have a system that allows someone to login to my wifi if they are a facebook friend? They log onto the wifi, they are presented with a captive portal to log into, it offers them a facebook login, the facebook DNS/IPs are whitelisted and they are able to sign in. If they are a friend of mine they are automatically logged into the wifi and can now access the internet.

#### What if I don't like facebook
Well if it's your home, you could just have them type in their name, once they press submit, a push notification appears on your phone asking if you want to give them access, if you accept they are granted access, simple.

#### How about if I run a restaurant?
Well facebook is your friend there too, you can ban people much more effectively than any system you could create, you can ask them to do things like "like your page" before they get access and you get their email address to contact for promotional material later. Your customers will be less creeped out than they will be glad of the convenience and you could go with the above option as an alternative for anyone who complains.

### Authorisation
The other problem with wifi is that the majority of routers give immediate access to all resources on the network once connected and if you want to change that well you'd better be a network expert because that is going to be super complicated for no good reason.

For christ sakes I have to opt in to pairing bluetooth speakers together, why is it that all the devices on my network are automatically paired together and are able to communicate without a second thought. Surely we could make it so that to remove a very hard firewall between connected devices we had to explicitly allow that action to take place?

### Conclusion

I think in order for changes like these to happen there will need to be a solution that not only addresses these problems with wifi, but many others in order to gain the necessary traction. However the fact that we are still at this stage with wifi shows just how little investment there is in that area. Here's hoping that makes it an area ripe for disruption and not a graveyard for innovation.