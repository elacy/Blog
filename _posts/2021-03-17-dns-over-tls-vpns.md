---
title: DNS over TLS and VPNs
layout: post
categories:
  - Technology
tags:
  - DNS
  - TLS
  - Security
  - Privacy
  - VPN
---

![](/assets/images/2021/03/17/dns-over-tls-vpns/secureLaptop.jpg "VPN & Internet Security on Your Computer for Online Privacy by mikemacmarketing is licensed with CC BY 2.0. To view a copy of this license, visit https://creativecommons.org/licenses/by/2.0/ ")

I keep seeing ads for various VPN providers claiming they can protect me on the internet and it sort of makes sense in a way. I'm going to break down how DNS over TLS may be a better option.<!-- more -->

The internet is a massive network of computers and when your computer connects to the internet it is one of those machines but the internet space you are using doesn't usually belong to you but rather the ISP you are paying for the privilege. You connect to the ISP and they rent out one of their Internet addresses to you, every web browser refresh and email you send goes through the ISP's servers as messages and is then directed toward the destination address included in the message, the response to your request for google.com is sent back through the network to your IP address and the ISP then sends that response back to you.

Most of the data you send through the internet is encrypted (and even more so if you install [https everywhere](https://addons.mozilla.org/en-US/firefox/addon/https-everywhere/)) meaning it can only be read by someone who has the encryption key which is hopefully just the ultimate recipient of the message but some of the data you send isn't, for example when you make a DNS request (give me the IP address for a given domain) that isn't encrypted. That means everytime you type the name of a website into your browser your ISP knows where you are going. This can be problematic because we can tell a lot about what you are doing based on which websites you visit and even just the size of the content sent back and forth even if it's encrypted.

Worse still if you are using a wireless network and you are not using EAP, you broadcast this information wirelessly so that anyone within range can see which websites you are looking at and WPA2 isn't very effective unless your key is quite long. If this is a public wifi they can probably already get the key and then see what you are up to. 

VPNs achieve 2 things, they protect your traffic from interception on the way to the VPN and they obscure your identity as defined by your ISP. All someone who is listening to your trafic whether they be someone who is also on your wireless network or your ISP is that you are using a VPN. If someone wants to find out who you are then they need to either connect the IP address provided by the VPN to your identity somehow or they can try to get the VPN to give them the ISP IP address and the ISP to give your home address. So that can make it a lot easier to protect yourself on the internet as long as you trust that the VPN provider is more trustworthy then your ISP. 

However it costs money and it makes your internet slower so how useful is it really? Well, it's not very helpful for privacy because usually everything is encrypted on the internet already aside from DNS and you could just use DNS over TLS which would solve that problem and it actually might be a more secure solution than VPN and it's free. The only thing you would be leaking is the IP addresses you connect to, the size and frequency of requests/responses.

DNS over TLS is encrypted DNS requests. With normal DNS you provide an IP address for the server you are going to use to lookup the domains of google.com etc, with DNS over TLS you provide an IP address and a domain name, DNS over TLS will then try to connect to that IP address and verify that the encrption certificate used by that IP address matches the the domain name you provided and then creates a secure channel. You do give away your DNS requests to that server however they can't see your other traffic so it's harder for them to connect the two together. 

Additionally if you have a router than supports DNS over TLS you can intercept all DNS requests made by devices that don't support it with an outgoing NAT rule that redirects all connections to port 53 to your router DNS which forwards the DNS request to a server that supports DNS over TLS. If you are using PFSense you can find the instructions for how to set that up [here](https://docs.netgate.com/pfsense/en/latest/recipes/dns-over-tls.html).
