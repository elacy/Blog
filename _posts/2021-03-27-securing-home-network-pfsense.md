---
title: Securing my home network with PFSense
layout: post
categories:
  - Technology
tags:
  - Security
  - PFSense
  - Networking
  - Homelab
  - Firewall
---

![](/assets/images/2021/03/27/securing-home-network-pfsense/firewall.jpg "Wie eine Firewall arbeitet / how a firewall works by pittigliani2005 is licensed under CC BY-NC-ND 2.0")

I decided I wanted to secure my home network so I decided to go as extreme as possible without the major inconvenience and while it was frustrating at times it was also a lot of fun. Here is a description of my setup warts and all, and some of the things I couldn’t get working. <!-- more -->

### Physical Network
![](/assets/images/2021/03/27/securing-home-network-pfsense/physicalDiagram.png "Physical Network Diagram")

- Netgate SG-3100: Firewall
- Ubiquiti Cloud Key: Unifi Controller
- Ubiquiti AP-LR: Ceiling mounted AP
- Ubiquiti Flex HD: Stick it wherever AP
- TP-Link TL-PA7017P: Passthrough Powerline adapters with encryption
- Ubiquiti UniFi US-8 PoE: Switch with one PoE out port

I’m not a hardware expert so I didn’t try to build my own PFSense which I occasionally feel regret over but the support provided by Netgate is really handy. I did have one bad update to the device but they fixed it pretty quickly and rolling back required asking for a previous image which sucked but it wasn’t too time-consuming.

I like the signal provided by the AP-LR, it isn’t all that overkill given my house is reasonably big and we have a shed in the back garden where my housemates smoke and watch Netflix so it works out well. The Flex HD may have been overkill but I do like that even if one wireless device goes down there is another one that can sort of fill its role in the interim.

Passthrough powerline is essential if you only have one socket and other devices need the power. It is possible to encrypt the traffic over the powerline by pairing the devices but I don’t know how much in the way of security this provides. I wasn’t particularly interested in spending time on it.


### Wireless Networks
- IoT: WPA2 with a password over 30 characters of random noise
- RES: WPA2 with a longish password for phones and laptops
- EAP: WPA2 TLS for phones, laptops, and a printer

PFSense comes with a certificate authority so you can create the client certificates in the UI and you just need your common name to be the same as the username in the free radius configuration, you can do all of this through the UI, super easy. Each device has its own TLS cert and the free radius validates their mac address before letting them on the network, I’ve covered how to do that [here](/technology/2021/03/16/mac-filtering-freeradius-pfsense.html). IoT and RES both do mac filtering.

### VLANs
- IoT: All the smart devices go on this subnet
- SIOT: Physically connected or connected via EAP goes here
- RES: Phones and laptops via WPA2
- SRES: Phones and laptops via WPA2 EAP TLS
- SERV: Rancher K8s running on RancherOS
- LAN: Used in case of a lockout, requires physical ethernet connection to the router.
- NET: All the Unifi devices

The IoT and RES wireless networks have fixed VLANs, EAP assigns the VLAN based on the response from the FreeRadius server running on the Netgate. Smart Things device connected to the switch is automatically tagged as SIOT, and there is a mac filter on this and the controller.

### DHCP
I did everything on IPv4, each VLAN gets its own `/24` block, all my static leases start at 64 so I can refer to them as `192.168.*.64/26` which doesn’t include `.1` , whereas the dynamic leases start at 128 so they aren’t included in that. I’ve turned on static arp for SRES, NET, SIOT, and IOT so dynamic leases won’t work on those, the router will just reject any traffic.

### Firewall
I made good use of the aliases especially given the work I put in to ensure that it’s difficult to fake an IP address here. I also created an alias for anything IANA reserved addresses which I call IANAReserved, then for the /24 ranges I call them client ranges. Client ranges can access DNS on the firewall, plus they can access anything that isn’t an internal address freely as long as it’s not explicitly blocked by Pfblockerng.

People who are on the RES and SRES networks can access services on SERV, can access Spotify connect on the devices that support it and the printer. I can additionally access the management interfaces for the Unifi Controller, the router, my ISP's devices, and the printer. The firewall is super intuitive and quite powerful, you can very quickly set it up, and being able to add name separators makes a huge difference to its power.

If I want to do some testing which requires giving some machines extra access that I don’t want to leave in place permanently, I can create a schedule that is limited to the next few hours and then add any new rules to that schedule so once they expire the firewall will no longer accept traffic. Very useful in case you forget to remove rules you were using for testing.

### DNS and SSL
I have a domain so I use dns01 Letsencrypt on that to get my SSL so I don’t need to publically expose services I want to secure using SSL. PFSense is super easy to get that working for, Unifi is a different story, to get that working you are going to need to look through a lot of worked examples, it’s going to involve at least some SSH.

For DNS I ended up using the resolver rather than the forwarder but I forward my queries to Cloudflare I explain why in a bit more detail [here](/technology/2021/03/17/dns-over-tls-vpns.html) but essentially it comes down to separation between people who can analyze my traffic and my DNS requests. I also use an outgoing nat rule that redirects all outgoing traffic on port 53 to the Netgate aside from the SERV network where I need direct access to DNS. This is mostly for making sure IoT devices aren’t going to evade my PFBlockerNG.

### PFBlockerNG
I did turn this on but the idea is to protect against malware primarily as I can run adblocker on my browser if I need to. I’m going to have to hook this up to my monitoring system before I can properly analyze the impact of this. It would be nice to have different levels for different parts of the network, I have no problem if my IOT are restricted from accessing tracking sites but I’m a little wary of pissing off my housemates or creating difficult-to-diagnose issues while I’m attempting to do paid work. So I haven’t dug too deeply into this.

### Suricata/Snort
I did set this up and it was interesting but far too many false positives to be useful and it ate up so much CPU/RAM. I did discover I can run it on the LAN interface and it works across all my VLANs which was nice but it’s still a pretty heavy-duty load and until I can have some way of measuring the impact on performance I’m going to give it a miss for now.

### SyslogNG
I managed to get this working, pointed the default Syslog here and also the Syslog from the Unifi devices. SyslogNG then forwards this onto the SERV network where I have a Graylog server which allows me to see in nice dashboards which devices are being blocked frequently but also which devices are having trouble authenticating to the network through the same interface. This does not automatically give you PFBlockerNG logs and once I’m done installing Qubes I’m going to give that a go.

### Packet Capture
This is an incredible feature that allows you to grab packets on any interface with a filter of your choosing and then load that into Wireshark which is super helpful and a great way of learning how all of this works.

### Device Discovery across VLANs
I managed to get this working for my Alexas (Spotify connect) and for my printer because both of them use mDNS but if your Chromecast device for some reason uses SSDP then you are going to be in trouble cause the documentation for that is much more limited, I’m currently digging through cisco documentation to be able to understand how PIMD works. It’s not pretty, to put it mildly, hopefully, I’ll find a solution and then I have something else to blog about, but I imagine I’m going to end up writing more about the failed attempts than success at least for a while, it’s not easy.

### Quality of Service
I just used the PFSense wizard to set it up, it’s super complicated to play with and I’m not sure how most of it works but you can quickly make it deprioritize BitTorrent traffic, and prioritize VOIP which also includes VPN traffic. Given the prioritization works per interface, I find the UI rather confusing but I may appreciate the flexibility if I ever get into enough.

### Conclusion
If you are interested in learning about networking and security I highly recommend trying a setup like this out, I had a lot of fun playing with it and it does give you a sense of control about your network. Let me know if you found this useful!